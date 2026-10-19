// MS-2026-10: Go twin of bench.dats (same workloads, same output format).
// usage: bench NAME [N]    (GOMAXPROCS=1 for the single-thread comparison)
package main

import (
	"fmt"
	"os"
	"runtime"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"
)

var sink int

func report(name string, n int, t0 time.Time) {
	fmt.Println(name, n, time.Since(t0).Nanoseconds())
}

// spawnBatch runs b empty goroutines to completion.
func spawnBatch(b int) {
	var wg sync.WaitGroup
	wg.Add(b)
	for i := 0; i < b; i++ {
		go func() { sink++; wg.Done() }()
	}
	wg.Wait()
}

// benchSpawn: steady state, after one untimed warm-up batch of 10000.
func benchSpawn(n int) {
	spawnBatch(10000)
	t0 := time.Now()
	for k := n; k > 0; {
		b := min(k, 10000)
		spawnBatch(b)
		k -= b
	}
	report("spawn", n, t0)
}

// benchSpawnCold: exactly one batch of n, no warm-up.
func benchSpawnCold(n int) {
	t0 := time.Now()
	spawnBatch(n)
	report("spawn_cold", n, t0)
}

func benchYield(n int) {
	t0 := time.Now()
	var wg sync.WaitGroup
	wg.Add(2)
	for j := 0; j < 2; j++ {
		go func() {
			for i := 0; i < n; i++ {
				runtime.Gosched()
			}
			wg.Done()
		}()
	}
	wg.Wait()
	report("yield", 2*n, t0)
}

func benchPingpong(n int) {
	t0 := time.Now()
	c1, c2 := make(chan int, 1), make(chan int, 1)
	done := make(chan struct{}, 2)
	go func() {
		for k := 0; k < n; k++ {
			c1 <- k
			<-c2
		}
		done <- struct{}{}
	}()
	go func() {
		for k := 0; k < n; k++ {
			x := <-c1
			c2 <- x
		}
		done <- struct{}{}
	}()
	<-done
	<-done
	report("pingpong", 2*n, t0)
}

func benchProd(name string, p, n int) {
	t0 := time.Now()
	ch := make(chan int, 128)
	per := n / p
	var wg sync.WaitGroup
	wg.Add(p)
	for i := 0; i < p; i++ {
		go func() {
			for k := per; k > 0; k-- {
				ch <- k
			}
			wg.Done()
		}()
	}
	s := 0
	for i := 0; i < per*p; i++ {
		s += <-ch
	}
	sink = s
	wg.Wait()
	report(name, per*p, t0)
}

func benchChain(n int) {
	t0 := time.Now()
	first := make(chan int, 1)
	left := first
	for i := 0; i < n; i++ {
		right := make(chan int, 1)
		go func(l, r chan int) { l <- 1 + <-r }(left, right)
		left = right
	}
	left <- 0
	if x := <-first; x != n {
		panic("chain")
	}
	report("chain", n, t0)
}

func benchSieve(n int) {
	t0 := time.Now()
	c0 := make(chan int, 1)
	go func() {
		for k := 2; ; k++ {
			c0 <- k
		}
	}()
	ch := c0
	for i := 0; i < n; i++ {
		p := <-ch
		sink = p
		nx := make(chan int, 1)
		go func(in, out chan int, p int) {
			for {
				if x := <-in; x%p != 0 {
					out <- x
				}
			}
		}(ch, nx, p)
		ch = nx
	}
	report("sieve", n, t0)
}

func rssKB() int {
	b, _ := os.ReadFile("/proc/self/status")
	for _, l := range strings.Split(string(b), "\n") {
		if strings.HasPrefix(l, "VmRSS:") {
			v, _ := strconv.Atoi(strings.Fields(l)[1])
			return v
		}
	}
	return -1
}

func benchMem(n int) {
	r0 := rssKB()
	t0 := time.Now()
	ch := make(chan int, 1)
	var wg sync.WaitGroup
	wg.Add(n)
	started := make(chan struct{}, n)
	for i := 0; i < n; i++ {
		go func() { started <- struct{}{}; <-ch; wg.Done() }()
	}
	for i := 0; i < n; i++ {
		<-started
	}
	time.Sleep(50 * time.Millisecond) // let them all reach the receive
	runtime.Gosched()
	r1 := rssKB()
	close(ch)
	wg.Wait()
	fmt.Println("mem", n, time.Since(t0).Nanoseconds(), "rss_kb_per_task", float64(r1-r0)/float64(n))
}

// ---- M:N workloads (run with GOMAXPROCS=N; same work as the afiber side) ----

func benchMnPingpong(total int) {
	const P = 16
	n := total / (2 * P)
	t0 := time.Now()
	var wg sync.WaitGroup
	wg.Add(2 * P)
	for p := 0; p < P; p++ {
		c1, c2 := make(chan int, 1), make(chan int, 1)
		go func() {
			for k := 0; k < n; k++ {
				c1 <- k
				<-c2
			}
			wg.Done()
		}()
		go func() {
			for k := 0; k < n; k++ {
				x := <-c1
				c2 <- x
			}
			wg.Done()
		}()
	}
	wg.Wait()
	report("mn_pingpong", 2*n*P, t0)
}

func benchMnPipeline(n0 int) {
	const K = 8
	per := n0 / K
	n := per * K
	t0 := time.Now()
	a, b := make(chan int, 128), make(chan int, 128)
	var wg sync.WaitGroup
	wg.Add(K + 1)
	go func() {
		for k := n; k > 0; k-- {
			a <- k
		}
		wg.Done()
	}()
	for i := 0; i < K; i++ {
		go func() {
			for j := 0; j < per; j++ {
				b <- <-a + 1
			}
			wg.Done()
		}()
	}
	s := 0
	for i := 0; i < n; i++ {
		s += <-b
	}
	sink = s
	wg.Wait()
	report("mn_pipeline", n, t0)
}

var acc atomic.Uint64

func lcg(x uint64) uint64 { return x*6364136223846793005 + 1442695040888963407 }

func benchMnCpu(total int) {
	const K = 64
	iters := total / K
	t0 := time.Now()
	var wg sync.WaitGroup
	wg.Add(K)
	for k := 1; k <= K; k++ {
		go func(x uint64) {
			for i := 0; i < iters; i++ {
				if i%1000 == 999 {
					runtime.Gosched()
				}
				x = lcg(x)
			}
			acc.Add(x)
			wg.Done()
		}(uint64(k))
	}
	wg.Wait()
	report("mn_cpu", K*iters, t0)
}

func benchMnSpawn(n int) {
	var cnt atomic.Int64
	t0 := time.Now()
	for k := n; k > 0; {
		b := min(k, 1000)
		var wg sync.WaitGroup
		wg.Add(b)
		for i := 0; i < b; i++ {
			go func() { cnt.Add(1); wg.Done() }()
		}
		wg.Wait()
		k -= b
	}
	if int(cnt.Load()) != n {
		panic("mn_spawn")
	}
	report("mn_spawn", n, t0)
}

func benchMnMutex(total int) {
	const F = 32
	per := total / F
	t0 := time.Now()
	var mu sync.Mutex
	var wg sync.WaitGroup
	cnt := 0
	wg.Add(F)
	for i := 0; i < F; i++ {
		go func() {
			for k := 0; k < per; k++ {
				mu.Lock()
				cnt++
				mu.Unlock()
			}
			wg.Done()
		}()
	}
	wg.Wait()
	if cnt != per*F {
		panic("mn_mutex")
	}
	report("mn_mutex", per*F, t0)
}

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: bench NAME [N]")
		os.Exit(1)
	}
	n := 0
	if len(os.Args) > 2 {
		n, _ = strconv.Atoi(os.Args[2])
	}
	switch os.Args[1] {
	case "spawn":
		benchSpawn(n)
	case "spawn_cold":
		benchSpawnCold(n)
	case "yield":
		benchYield(n)
	case "pingpong":
		benchPingpong(n)
	case "pipe":
		benchProd("pipe", 1, n)
	case "fanin":
		benchProd("fanin", 8, n)
	case "chain":
		benchChain(n)
	case "sieve":
		benchSieve(n)
	case "mem":
		benchMem(n)
	case "mn_pingpong":
		benchMnPingpong(n)
	case "mn_pipeline":
		benchMnPipeline(n)
	case "mn_cpu":
		benchMnCpu(n)
	case "mn_spawn":
		benchMnSpawn(n)
	case "mn_mutex":
		benchMnMutex(n)
	default:
		fmt.Fprintln(os.Stderr, "unknown benchmark")
		os.Exit(1)
	}
}
