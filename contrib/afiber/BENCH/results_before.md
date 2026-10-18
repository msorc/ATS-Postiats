| benchmark | ops | afiber ns/op | go P=1 ns/op | go P=32 ns/op | afiber vs go P=1 |
|---|---:|---:|---:|---:|---:|
| spawn | 200000 | 14894.3 | 316.6 | 220.3 | 47.04x slower |
| yield | 1000000 | 502.0 | 68.6 | 114.1 | 7.32x slower |
| pingpong | 1000000 | 533.9 | 144.5 | 140.9 | 3.69x slower |
| pipe | 5000000 | 22.5 | 35.1 | 37.0 | 1.56x faster |
| fanin | 5000000 | 36.3 | 35.2 | 50.6 | 1.03x slower |
| chain | 30000 | 15500.9 | 1745.3 | 1423.5 | 8.88x slower |
| sieve | 1500 | 485677.2 | 112222.8 | 26844.5 | 4.33x slower |

| memory (parked fibers) | tasks | afiber KB/task | go P=1 KB/task | go P=32 KB/task |
|---|---:|---:|---:|---:|
| mem | 30000 | 5.10 | 2.71 | 3.20 |
