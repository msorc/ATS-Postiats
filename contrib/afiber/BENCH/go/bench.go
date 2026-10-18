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
	"time"
)

var sink int

func report(name string, n int, t0 time.Time) {
	fmt.Println(name, n, time.Since(t0).Nanoseconds())
}

func benchSpawn(n int) {
	t0 := time.Now()
	for k := n; k > 0; {
		b := min(k, 10000)
		var wg sync.WaitGroup
		wg.Add(b)
		for i := 0; i < b; i++ {
			go func() { sink++; wg.Done() }()
		}
		wg.Wait()
		k -= b
	}
	report("spawn", n, t0)
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
	default:
		fmt.Fprintln(os.Stderr, "unknown benchmark")
		os.Exit(1)
	}
}
