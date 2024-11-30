# 从零到一学Golang
- [什么是GO语言](#%E4%BB%80%E4%B9%88%E6%98%AFGO%E8%AF%AD%E8%A8%80)
- [Go语言的目录结构](#Go%E8%AF%AD%E8%A8%80%E7%9A%84%E7%9B%AE%E5%BD%95%E7%BB%93%E6%9E%84)
	- [GOROOT](#GOROOT)
	- [GOPATH](#GOPATH)
	- [golang编程规范-项目目录结构](#golang%E7%BC%96%E7%A8%8B%E8%A7%84%E8%8C%83-%E9%A1%B9%E7%9B%AE%E7%9B%AE%E5%BD%95%E7%BB%93%E6%9E%84)
- [新建一个golang项目](#%E6%96%B0%E5%BB%BA%E4%B8%80%E4%B8%AAgolang%E9%A1%B9%E7%9B%AE)
	- [在GOLAND中新建项目](#%E5%9C%A8GOLAND%E4%B8%AD%E6%96%B0%E5%BB%BA%E9%A1%B9%E7%9B%AE)
- [命名规范](#%E5%91%BD%E5%90%8D%E8%A7%84%E8%8C%83)
	- [包名（Package Names）](#%E5%8C%85%E5%90%8D%EF%BC%88Package%20Names%EF%BC%89)
	- [变量名（Variable Names）](#%E5%8F%98%E9%87%8F%E5%90%8D%EF%BC%88Variable%20Names%EF%BC%89)
	- [常量名（Constant Names）](#%E5%B8%B8%E9%87%8F%E5%90%8D%EF%BC%88Constant%20Names%EF%BC%89)
	- [函数名（Function Names）](#%E5%87%BD%E6%95%B0%E5%90%8D%EF%BC%88Function%20Names%EF%BC%89)
	- [结构体名（Struct Names）](#%E7%BB%93%E6%9E%84%E4%BD%93%E5%90%8D%EF%BC%88Struct%20Names%EF%BC%89)
	- [接口名（Interface Names）](#%E6%8E%A5%E5%8F%A3%E5%90%8D%EF%BC%88Interface%20Names%EF%BC%89)
	- [方法名（Method Names）](#%E6%96%B9%E6%B3%95%E5%90%8D%EF%BC%88Method%20Names%EF%BC%89)
	- [缩写（Acronyms）](#%E7%BC%A9%E5%86%99%EF%BC%88Acronyms%EF%BC%89)
	- [文件名（File Names）](#%E6%96%87%E4%BB%B6%E5%90%8D%EF%BC%88File%20Names%EF%BC%89)
	- [注释（Comments）](#%E6%B3%A8%E9%87%8A%EF%BC%88Comments%EF%BC%89)
- [Golang内置类型和函数](#Golang%E5%86%85%E7%BD%AE%E7%B1%BB%E5%9E%8B%E5%92%8C%E5%87%BD%E6%95%B0)
	- [内置类型](#%E5%86%85%E7%BD%AE%E7%B1%BB%E5%9E%8B)
		- [值类型](#%E5%80%BC%E7%B1%BB%E5%9E%8B)
			- [布尔型bool](#%E5%B8%83%E5%B0%94%E5%9E%8Bbool)
			- [整数类型int](#%E6%95%B4%E6%95%B0%E7%B1%BB%E5%9E%8Bint)
			- [无符号整数类型uint](#%E6%97%A0%E7%AC%A6%E5%8F%B7%E6%95%B4%E6%95%B0%E7%B1%BB%E5%9E%8Buint)
			- [浮点类型float](#%E6%B5%AE%E7%82%B9%E7%B1%BB%E5%9E%8Bfloat)
			- [字符串类型string](#%E5%AD%97%E7%AC%A6%E4%B8%B2%E7%B1%BB%E5%9E%8Bstring)
			- [复数类型complex](#%E5%A4%8D%E6%95%B0%E7%B1%BB%E5%9E%8Bcomplex)
			- [数组类型array](#%E6%95%B0%E7%BB%84%E7%B1%BB%E5%9E%8Barray)
		- [引用类型：(指针类型)](#%E5%BC%95%E7%94%A8%E7%B1%BB%E5%9E%8B%EF%BC%9A(%E6%8C%87%E9%92%88%E7%B1%BB%E5%9E%8B))
			- [切片（Slice）](#%E5%88%87%E7%89%87%EF%BC%88Slice%EF%BC%89)
			- [映射（Map）](#%E6%98%A0%E5%B0%84%EF%BC%88Map%EF%BC%89)
			- [通道（Channel）](#%E9%80%9A%E9%81%93%EF%BC%88Channel%EF%BC%89)
	- [内置函数](#%E5%86%85%E7%BD%AE%E5%87%BD%E6%95%B0)
		- [append](#append)
		- [close](#close)
		- [delete](#delete)
		- [panic](#panic)
		- [recover](#recover)
		- [imag](#imag)
		- [real](#real)
		- [make](#make)
		- [new](#new)
		- [cap](#cap)
		- [copy](#copy)
		- [len](#len)
		- [print和println](#print%E5%92%8Cprintln)
	- [内置接口error](#%E5%86%85%E7%BD%AE%E6%8E%A5%E5%8F%A3error)
		- [`error` 接口定义](#%60error%60%20%E6%8E%A5%E5%8F%A3%E5%AE%9A%E4%B9%89)
		- [创建和返回错误](#%E5%88%9B%E5%BB%BA%E5%92%8C%E8%BF%94%E5%9B%9E%E9%94%99%E8%AF%AF)
		- [自定义错误类型](#%E8%87%AA%E5%AE%9A%E4%B9%89%E9%94%99%E8%AF%AF%E7%B1%BB%E5%9E%8B)
		- [包装错误](#%E5%8C%85%E8%A3%85%E9%94%99%E8%AF%AF)
		- [解包错误](#%E8%A7%A3%E5%8C%85%E9%94%99%E8%AF%AF)
		- [判断错误类型](#%E5%88%A4%E6%96%AD%E9%94%99%E8%AF%AF%E7%B1%BB%E5%9E%8B)
		- [总结](#%E6%80%BB%E7%BB%93)
- [Init函数和main函数](#Init%E5%87%BD%E6%95%B0%E5%92%8Cmain%E5%87%BD%E6%95%B0)
	- [main函数](#main%E5%87%BD%E6%95%B0)
	- [init函数](#init%E5%87%BD%E6%95%B0)
	- [多个init函数](#%E5%A4%9A%E4%B8%AAinit%E5%87%BD%E6%95%B0)
	- [Init和Main的区别](#Init%E5%92%8CMain%E7%9A%84%E5%8C%BA%E5%88%AB)


## 什么是GO语言

Go（又称Golang）是一种由Google开发的开源编程语言，首次发布于2009年。它由Robert Griesemer、Rob Pike和Ken Thompson设计，旨在解决大型软件系统开发中的常见问题。以下是Go语言的一些关键特点和优势：

- **简洁性和易读性**
 Go语言设计简洁，语法简单，易于学习和使用。它去除了许多传统编程语言中的复杂特性，如继承、泛型和异常处理，取而代之的是更直观的语法和结构。
- **高效的并发编程**
 Go语言内置了对并发编程的支持，使用goroutines和channels，使得开发高效的并发程序变得非常简单。goroutines是轻量级的线程，可以在数千个goroutines之间高效调度。
- **性能**
 Go语言编译成机器码，执行速度非常快。它的性能接近于C和C++，但开发效率更高。内存管理通过垃圾回收（Garbage Collection）来实现，减少了手动管理内存的复杂性。
- **跨平台**
 Go语言支持多平台编译，可以轻松地编译为Windows、Linux、macOS等操作系统的可执行文件。其编译器和工具链非常强大，支持静态链接，生成的二进制文件无需依赖其他库。
- **强大的标准库**
 Go语言提供了一个丰富且高效的标准库，涵盖了网络、文件I/O、文本处理、加密等常见功能，开发者可以直接使用这些库快速构建应用程序。
- **工具支持**
 Go语言提供了一套强大的工具链，包括格式化工具（`gofmt`）、测试工具（`go test`）、包管理工具（`go mod`）等，极大地提高了开发效率和代码质量。
- **静态类型和编译时检查**
 Go语言是静态类型语言，类型检查在编译时进行，这有助于捕获许多潜在的错误，提供更高的代码安全性。
- **社区和生态系统**
 Go语言有一个活跃的开发者社区和丰富的第三方库生态系统。许多大型项目和公司（如Docker、Kubernetes、Uber等）都使用Go语言开发，进一步推动了其发展和普及。

## Go语言的目录结构

Go语言的目录结构包括开发包目录（GOROOT）和工作区目录（GOPATH）

### GOROOT

GOROOT是GO语言环境的根目录，打开GO语言安装包的安装路径即可看到GOROOT目录结构中的内容。里面包括一下文件夹：

- api文件夹：存放了Go API检查器的辅助文件，包括公开的变量，常量及函数等。except.txt文件中存放了一些（在不破坏兼容性的前提下）可能会消失的api特性。next.txt文件则存放了可能在下一版本中添加的新API特性。
- bin文件夹：bin文件夹中存放了所有由官方提供的Go语言相关工具的可执行文件。默认情况下，该目录会包含go和gofmt这两个工具。
- doc文件夹：存放了Go语言几乎全部html格式的官方文档说明，方便离线查看
- lib文件夹：存放引用的库文件，可以为程序的运行提供帮助
- misc文件夹： 存放各类编辑器或IDE(集成开发环境)软件的插件，辅助开发者查看和编写Go语言代码
- pkg文件夹： 用于在构建安装后，保存Go语言标准库的所有归档文件。
- src文件夹： 用于存放所有标准库，Go语言工具及相关底层库（C语言实现）的源码
- test文件夹： 存放了测试Go语言自身代码的文件2.

### GOPATH

GOPATH工作区有三个子目录，分别是src目录，pkg目录和bin目录

- src目录： 主要用于以代码包的形式组织并保存Go源代码文件。Go语言的源码文件分为三种，即Go库源码文件，Go命令源码文件和Go测试源码文件
- pkg目录： 用于存放经由go install命令构建安装后的代码包（包含Go库源码文件）的“.a”归档文件。
- bin目录： 在通过go install命令完成安装后，保存由Go命令源码文件生成的可执行文件

### golang编程规范-项目目录结构

[目录结构规范](https://blog.csdn.net/baidu_32452525/article/details/141114507)

## 新建一个golang项目

### 在GOLAND中新建项目

1. 在Goland中新建项目，选择项目存放的路径以及项目名称，并设置项目GOPATH为当前项目路径,然后点击创建就好了。
![image.png](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20240918133149.png)
![image.png](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20240918133251.png)
2. 使用`go mod init myProject`命令来初始化项目，此命令的主要作用是初始化一个新的 Go 模块，创建并配置 `go.mod` 文件，以便于管理项目的依赖关系和版本控制。这是现代 Go 项目开发的标准做法，有助于提高项目的可维护性和可移植性。

 ```go
 go mod init myproject
 ```

此时的项目文件是这样的
![image.png](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20240918140358.png)

## 命名规范

### 包名（Package Names）

- **简短且有意义**：包名应该简短但有意义，通常使用单个词。
- **小写字母**：包名应该全部使用小写字母，避免使用下划线或大写字母。

```go
package math
```

### 变量名（Variable Names）

- **驼峰命名法（CamelCase）**：变量名通常使用驼峰命名法，第一个字母小写。
- **简短且有意义**：变量名应该简短但描述性强。

```go
var userName string
var age int
```

### 常量名（Constant Names）

- **驼峰命名法（CamelCase）**：常量名通常使用驼峰命名法。
- **大写字母开头**：导出的常量名（即可以被其他包访问的常量）应该以大写字母开头。

```go
const Pi = 3.14
const maxRetries = 5
```

### 函数名（Function Names）

- **驼峰命名法（CamelCase）**：函数名使用驼峰命名法。
- **大写字母开头**：导出的函数名（即可以被其他包访问的函数）应该以大写字母开头。

```go
func CalculateArea(radius float64) float64 {
    return Pi * radius * radius
}

func newUser(name string, age int) *User {
    return &User{Name: name, Age: age}
}
```

### 结构体名（Struct Names）

- **驼峰命名法（CamelCase）**：结构体名使用驼峰命名法。
- **大写字母开头**：导出的结构体名（即可以被其他包访问的结构体）应该以大写字母开头。

```go
type User struct {
    Name string
    Age  int
}
```

### 接口名（Interface Names）

- **驼峰命名法（CamelCase）**：接口名使用驼峰命名法。
- **通常以-er结尾**：接口名通常以-er结尾，以表示行为。

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}
```

### 方法名（Method Names）

- **驼峰命名法（CamelCase）**：方法名使用驼峰命名法。
- **大写字母开头**：导出的方法名（即可以被其他包访问的方法）应该以大写字母开头。

```go
func (u *User) GetName() string {
    return u.Name
}

func (u *User) setName(name string) {
    u.Name = name
}
```

### 缩写（Acronyms）

- **全大写**：常用缩写（如HTTP、URL）应该全大写，并在驼峰命名法中保持一致。

```go
var httpServer HTTPServer
var urlString string

type HTTPServer struct {
    Address string
}
```

### 文件名（File Names）

- **小写字母和下划线**：文件名应该使用小写字母和下划线分隔单词。

```go
user_service.go
database_connection.go
```

### 注释（Comments）

- **文档注释**：导出的包、函数、类型和变量应该有文档注释。这些注释应该完整描述其用途，并以其名称开头。

```go
//单行注释
// User represents a user in the system.
type User struct {
    Name string // Name is the name of the user.
    Age  int    // Age is the age of the user.
}

// NewUser creates a new User with the given name and age.
func NewUser(name string, age int) *User {
    return &User{Name: name, Age: age}
}

//多行注释
/* This is a multi-line comment using block comment syntax. It can span multiple lines and is enclosed within slash-asterisk and asterisk-slash. */
```

## Golang内置类型和函数

### 内置类型

#### 值类型

```go
bool
int(32 or 64), int8, int16, int32, int64
uint(32 or 64), uint8(byte), uint16, uint32, uint64
float32, float64
string
complex64, complex128
array //固定长度的数组
```

以下是 Go 语言中各种值类型的默认值：

- `bool`：`false`
- `int`, `int8`, `int16`, `int32`, `int64`：`0`
- `uint`, `uint8`（`byte`）, `uint16`, `uint32`, `uint64`：`0`
- `float32`, `float64`：`0`
- `string`：空字符串 `""`
- `complex64`, `complex128`：`(0+0i)`
- 数组：所有元素的默认值，例如 `[0 0 0 0 0]`（对于整型数组）

在 Go 语言中，值类型包括布尔型、整数型、浮点型、字符串、复数、数组等。每种类型都有其特定的用法和默认值。下面将详细介绍这些值类型的使用方法和默认值。

##### 布尔型bool

使用方法
布尔型用于表示真或假，只有两个可能的值：`true` 和 `false`。

示例

```go
package main

import "fmt"

func main() {
    var b bool
    fmt.Println(b) // 默认值为 false

    b = true
    fmt.Println(b) // 输出 true
}
```

默认值
布尔型的默认值是 `false`。

##### 整数类型int

使用方法
Go 语言提供了多种整数类型，包括有符号整数 (`int`, `int8`, `int16`, `int32`, `int64`) 和无符号整数 (`uint`, `uint8`, `uint16`, `uint32`, `uint64`)。

示例

```go
package main

import "fmt"

func main() {
    var i int
    var i8 int8
    var i16 int16
    var i32 int32
    var i64 int64

    fmt.Println(i, i8, i16, i32, i64) // 默认值均为 0

    i = 42
    i8 = 8
    i16 = 16
    i32 = 32
    i64 = 64

    fmt.Println(i, i8, i16, i32, i64)
}
```

默认值
所有整数类型的默认值都是 `0`。

##### 无符号整数类型uint

使用方法
无符号整数类型包括 `uint`, `uint8`（也称为 `byte`），`uint16`, `uint32`, `uint64`。

示例

```go
package main

import "fmt"

func main() {
    var u uint
    var u8 uint8
    var u16 uint16
    var u32 uint32
    var u64 uint64

    fmt.Println(u, u8, u16, u32, u64) // 默认值均为 0

    u = 42
    u8 = 8
    u16 = 16
    u32 = 32
    u64 = 64

    fmt.Println(u, u8, u16, u32, u64)
}
```

默认值
所有无符号整数类型的默认值都是 `0`。

##### 浮点类型float

使用方法
浮点类型包括 `float32` 和 `float64`，用于表示小数。

示例

```go
package main

import "fmt"

func main() {
    var f32 float32
    var f64 float64

    fmt.Println(f32, f64) // 默认值均为 0

    f32 = 3.14
    f64 = 2.71828

    fmt.Println(f32, f64)
}
```

默认值
所有浮点类型的默认值都是 `0`。

##### 字符串类型string

使用方法
字符串类型用于表示文本。

示例

```go
package main

import "fmt"

func main() {
    var s string
    fmt.Println(s) // 默认值为空字符串 ""

    s = "Hello, Go!"
    fmt.Println(s)
}
```

默认值
字符串类型的默认值是空字符串 `""`。

##### 复数类型complex

使用方法
复数类型包括 `complex64` 和 `complex128`，用于表示复数。

示例

```go
package main

import "fmt"

func main() {
    var c64 complex64
    var c128 complex128

    fmt.Println(c64, c128) // 默认值均为 (0+0i)

    c64 = complex(3, 4)
    c128 = complex(5, 6)

    fmt.Println(c64, c128)
}
```

默认值
所有复数类型的默认值都是 `(0+0i)`。

##### 数组类型array

使用方法
数组用于存储固定长度的同类型元素序列。

示例

```go
package main

import "fmt"

func main() {
    var arr [5]int
    fmt.Println(arr) // 默认值为 [0 0 0 0 0]

    arr = [5]int{1, 2, 3, 4, 5}
    fmt.Println(arr)
}
```

默认值
数组类型的默认值是所有元素的默认值。例如，整型数组的默认值是 `[0 0 0 0 0]`。

#### 引用类型：(指针类型)

在 Go 语言中，引用类型包括切片（`slice`）、映射（`map`）、通道（`chan`）。这些类型在 Go 中非常重要，用于处理动态数据结构、键值对存储以及并发编程。

- **切片（Slice）**：动态数组，可以动态调整大小，使用 `make` 函数或字面量创建。
- **映射（Map）**：键值对存储数据结构，使用 `make` 函数或字面量创建。
- **通道（Channel）**：用于 Goroutine 之间通信，使用 `make` 函数创建，可以是无缓冲或有缓冲的。

```go
slice -- 序列数组(最常用)
map -- 映射
chan -- 管道
```

##### 切片（Slice）

概念
切片是对数组的一个连续片段的引用，是动态数组，可以动态调整大小。切片比数组更灵活，更常用。

适用场景：
- **顺序存储数据**：当你需要存储一组有序的数据时，可以使用 `slice`。例如，存储一系列数字、字符串或结构体。
- **随机访问**：你可以通过索引快速访问 `slice` 中的元素，时间复杂度为 O(1)O(1)。
- **动态增长**：当你需要一个可以动态增长的数组时，`slice` 是非常合适的选择。Go 会在需要时自动扩展底层数组。
- **遍历操作**：`slice` 非常适合进行遍历操作，尤其是在你需要按顺序处理数据时。

使用方法

1. **声明和初始化**

```go
package main

import "fmt"

func main() {
    // 使用内置函数 make 创建切片
    s := make([]int, 5) // 创建一个长度和容量为 5 的切片
    fmt.Println(s) // 输出 [0 0 0 0 0]

    // 使用字面量创建切片
    s = []int{1, 2, 3, 4, 5}
    fmt.Println(s) // 输出 [1 2 3 4 5]

    // 基于数组创建切片
    arr := [5]int{10, 20, 30, 40, 50}
    s = arr[1:4]
    fmt.Println(s) // 输出 [20 30 40]
}
```

2. **切片操作**

```go
package main

import "fmt"

func main() {
    s := []int{1, 2, 3, 4, 5}
    
    // 获取子切片
    sub := s[1:3]
    fmt.Println(sub) // 输出 [2 3]

    // 修改切片元素
    s[2] = 10
    fmt.Println(s) // 输出 [1 2 10 4 5]

    // 添加元素
    s = append(s, 6)
    fmt.Println(s) // 输出 [1 2 10 4 5 6]

    // 拷贝切片
    t := make([]int, len(s))
    copy(t, s)
    fmt.Println(t) // 输出 [1 2 10 4 5 6]
}
```

##### 映射（Map）

概念
映射是一种键值对的数据结构，类似于其他语言中的字典或哈希表。

适用场景：

- **协程之间的通信**：`chan` 主要用于多个协程之间的同步和数据传递。它可以确保数据在多个协程之间安全传递。
- **同步和锁机制替代**：通过 `chan`，可以避免显式的锁（如 `mutex`），从而减少并发编程中的复杂性和错误。
- **阻塞和非阻塞**：`chan` 可以是阻塞的，也可以是非阻塞的，具体取决于是否有数据可以发送或接收

使用方法

1. **声明和初始化**

```go
package main

import "fmt"

func main() {
    // 使用内置函数 make 创建映射
    m := make(map[string]int)
    fmt.Println(m) // 输出 map[]

    // 使用字面量创建映射
    m = map[string]int{
        "one": 1,
        "two": 2,
    }
    fmt.Println(m) // 输出 map[one:1 two:2]
}
```

2. **映射操作**

```go
package main

import "fmt"

func main() {
    m := map[string]int{
        "one": 1,
        "two": 2,
    }

    // 添加或更新键值对
    m["three"] = 3
    fmt.Println(m) // 输出 map[one:1 three:3 two:2]

    // 获取值
    value := m["two"]
    fmt.Println(value) // 输出 2

    // 检查键是否存在
    value, exists := m["four"]
    if exists {
        fmt.Println(value)
    } else {
        fmt.Println("Key not found") // 输出 Key not found
    }

    // 删除键值对
    delete(m, "one")
    fmt.Println(m) // 输出 map[three:3 two:2]
}
```

##### 通道（Channel）

概念
通道是 Go 中用于在不同 Goroutine 之间进行通信的机制。通道可以同步发送和接收数据。

使用 `chan` 的典型场景：

- 需要在多个协程之间传递数据时，例如生产者-消费者模型。
- 需要确保多个协程之间的同步和协作。
- 需要通过通道来协调任务的完成，避免显式使用锁或条件变量的场景。

使用方法

1. **声明和初始化**

```go
package main

import "fmt"

func main() {
    // 创建一个无缓冲的通道
    ch := make(chan int)

    // 创建一个有缓冲的通道
    bufferedCh := make(chan int, 10)

    fmt.Println(ch, bufferedCh)
}
```

2. **通道操作**

```go
package main

import (
    "fmt"
    "time"
)

func main() {
    ch := make(chan int)

    // 启动一个 Goroutine 发送数据
    go func() {
        ch <- 42
    }()

    // 接收数据
    value := <-ch
    fmt.Println(value) // 输出 42

    // 使用缓冲通道
    bufferedCh := make(chan int, 2)
    bufferedCh <- 1
    bufferedCh <- 2

    fmt.Println(<-bufferedCh) // 输出 1
    fmt.Println(<-bufferedCh) // 输出 2

    // 使用通道进行同步
    done := make(chan bool)
    go func() {
        time.Sleep(time.Second)
        fmt.Println("Goroutine finished")
        done <- true
    }()
    <-done // 等待 Goroutine 完成
    fmt.Println("Main function finished")
}
```

### 内置函数

Go 语言拥有一些不需要进行导入操作就可以使用的内置函数。它们有时可以针对不同的类型进行操作，例如：len、cap 和 append，或必须用于系统级的操作，例如：panic。因此，它们需要直接获得编译器的支持。

```go
append   -- 用来追加元素到数组、slice中,返回修改后的数组、slice
close    -- 主要用来关闭channel
delete   -- 从map中删除key对应的value
panic    -- 停止常规的goroutine（panic和recover：用来做错误处理）
recover  -- 允许程序定义goroutine的panic动作
imag     -- 返回complex的实部（complex、real imag：用于创建和操作复数）
real     -- 返回complex的虚部
make     -- 用来分配内存，返回Type本身(只能应用于slice, map, channel)
new      -- 用来分配内存，主要用来分配值类型，比如int、struct。返回指向Type的指针
cap      -- capacity是容量的意思，用于返回某个类型的最大容量（只能用于切片和map）
copy     -- 用于复制和连接slice，返回复制的数目
len      -- 来求长度，比如string、array、slice、map、channel ，返回长度
print println  -- 底层打印函数，在部署环境中建议使用 fmt 包
```

#### append

`append` 用于向切片中添加元素。它返回一个包含新元素的切片。

使用方法

```go
package main

import "fmt"

func main() {
    s := []int{1, 2, 3}
    s = append(s, 4, 5, 6)
    fmt.Println(s) // 输出 [1 2 3 4 5 6]

    // 追加另一个切片
    t := []int{7, 8, 9}
    s = append(s, t...)
    fmt.Println(s) // 输出 [1 2 3 4 5 6 7 8 9]
}
```

#### close

`close` 用于关闭通道，表示不再有数据发送到该通道。

使用方法

```go
package main

import "fmt"

func main() {
    ch := make(chan int)
    go func() {
        for i := 0; i < 5; i++ {
            ch <- i
        }
        close(ch)
    }()
    for v := range ch {
        fmt.Println(v) // 输出 0 1 2 3 4
    }
}
```

#### delete

`delete` 用于从映射中删除键值对。

使用方法

```go
package main

import "fmt"

func main() {
    m := map[string]int{"a": 1, "b": 2, "c": 3}
    delete(m, "b")
    fmt.Println(m) // 输出 map[a:1 c:3]
}
```

#### panic

`panic` 用于引发一个恐慌，通常用于严重错误的处理。

使用方法

```go
package main

import "fmt"

func main() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("Recovered from panic:", r)
        }
    }()
    panic("Something went wrong")
}
```

#### recover

`recover` 用于恢复一个恐慌，通常与 `defer` 一起使用。

使用方法

```go
package main

import "fmt"

func main() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("Recovered from panic:", r)
        }
    }()
    panic("Something went wrong")
}
```

#### imag

`imag` 用于获取复数的虚部。

使用方法

```go
package main

import "fmt"

func main() {
    c := complex(2, 3)
    fmt.Println(imag(c)) // 输出 3
}
```

#### real

`real` 用于获取复数的实部。

使用方法

```go
package main

import "fmt"

func main() {
    c := complex(2, 3)
    fmt.Println(real(c)) // 输出 2
}
```

#### make

`make` 用于创建切片、映射和通道。

使用方法

```go
package main

import "fmt"

func main() {
    s := make([]int, 5)
    fmt.Println(s) // 输出 [0 0 0 0 0]

    m := make(map[string]int)
    fmt.Println(m) // 输出 map[]

    ch := make(chan int)
    fmt.Println(ch) // 输出 0xc0000180c0
}
```

#### new

`new` 用于分配内存，返回指向零值的指针。

使用方法

```go
package main

import "fmt"

func main() {
    p := new(int)
    fmt.Println(p)  // 输出内存地址
    fmt.Println(*p) // 输出 0
}
```

#### cap

`cap` 用于获取切片、数组或通道的容量。

使用方法

```go
package main

import "fmt"

func main() {
    s := make([]int, 5, 10)
    fmt.Println(cap(s)) // 输出 10

    ch := make(chan int, 3)
    fmt.Println(cap(ch)) // 输出 3
}
```

#### copy

`copy` 用于将一个切片的元素复制到另一个切片。

使用方法

```go
package main

import "fmt"

func main() {
    src := []int{1, 2, 3}
    dst := make([]int, len(src))
    copy(dst, src)
    fmt.Println(dst) // 输出 [1 2 3]
}
```

#### len

`len` 用于获取切片、数组、映射、字符串或通道的长度。

使用方法

```go
package main

import "fmt"

func main() {
    s := []int{1, 2, 3}
    fmt.Println(len(s)) // 输出 3

    m := map[string]int{"a": 1, "b": 2}
    fmt.Println(len(m)) // 输出 2

    str := "hello"
    fmt.Println(len(str)) // 输出 5
}
```

#### print和println

`print` 和 `println` 用于打印输出，但它们不如 `fmt` 包强大，主要用于调试。

使用方法

```go
package main

func main() {
    print("Hello, ")
    println("world!")
}
```

### 内置接口error

在Go语言中，`error` 是一个内置的接口，用于表示和处理错误。`error` 接口是 Go 语言中处理错误的基本机制。

#### `error` 接口定义

`error` 接口非常简单，只包含一个方法 `Error`，该方法返回一个字符串，描述了错误的具体信息。其定义如下：

```go
type error interface {
    Error() string
}
```

#### 创建和返回错误

Go 语言标准库提供了一个名为 `errors` 的包，用于创建和处理错误。最常用的方式是使用 `errors.New` 函数：

```go
import (
    "errors"
    "fmt"
)

func main() {
    err := errors.New("something went wrong")
    if err != nil {
        fmt.Println(err)
    }
}
```

#### 自定义错误类型

除了使用 `errors.New` 创建简单的错误信息外，您还可以定义自己的错误类型，以提供更多的上下文信息。自定义错误类型只需实现 `error` 接口的 `Error` 方法即可。

```go
package main

import (
    "fmt"
)

// MyError is a custom error type
type MyError struct {
    Code    int
    Message string
}

// Error implements the error interface for MyError
func (e *MyError) Error() string {
    return fmt.Sprintf("Error %d: %s", e.Code, e.Message)
}

func main() {
    err := &MyError{Code: 404, Message: "Resource not found"}
    if err != nil {
        fmt.Println(err)
    }
}
```

#### 包装错误

Go 1.13 引入了 `fmt.Errorf` 和 `errors` 包中的 `Unwrap`、`Is` 和 `As` 函数，提供了更强大的错误处理功能。您可以使用 `fmt.Errorf` 来包装错误，并添加更多上下文信息：

```go
import (
    "errors"
    "fmt"
)

func main() {
    originalErr := errors.New("original error")
    wrappedErr := fmt.Errorf("an error occurred: %w", originalErr)

    fmt.Println(wrappedErr)

    if errors.Is(wrappedErr, originalErr) {
        fmt.Println("The wrapped error contains the original error")
    }
}
```

#### 解包错误

使用 `errors.Unwrap` 可以解包被包装的错误：

```go
import (
    "errors"
    "fmt"
)

func main() {
    originalErr := errors.New("original error")
    wrappedErr := fmt.Errorf("an error occurred: %w", originalErr)

    unwrappedErr := errors.Unwrap(wrappedErr)
    fmt.Println(unwrappedErr)
}
```

#### 判断错误类型

使用 `errors.Is` 可以判断错误是否与特定错误相等：

```go
import (
    "errors"
    "fmt"
)

var ErrNotFound = errors.New("not found")

func main() {
    err := fmt.Errorf("an error occurred: %w", ErrNotFound)

    if errors.Is(err, ErrNotFound) {
        fmt.Println("The error is a 'not found' error")
    }
}
```

使用 `errors.As` 可以判断错误是否为特定类型，并获取该类型的错误：

```go
import (
    "errors"
    "fmt"
)

type MyError struct {
    Code    int
    Message string
}

func (e *MyError) Error() string {
    return fmt.Sprintf("Error %d: %s", e.Code, e.Message)
}

func main() {
    err := &MyError{Code: 404, Message: "Resource not found"}
    wrappedErr := fmt.Errorf("an error occurred: %w", err)

    var myErr *MyError
    if errors.As(wrappedErr, &myErr) {
        fmt.Printf("The error is a MyError with code %d and message: %s\n", myErr.Code, myErr.Message)
    }
}
```

#### 总结

`error` 接口是 Go 语言中处理错误的核心机制。通过实现 `error` 接口，您可以创建自定义错误类型，提供丰富的错误信息。Go 1.13 及以后的版本还提供了 `fmt.Errorf`、`errors.Unwrap`、`errors.Is` 和 `errors.As` 等函数，增强了错误处理的灵活性和功能。

## Init函数和main函数

### main函数

`main` 函数是 Go 程序的入口点。每个 Go 程序必须有一个 `main` 包，并且在 `main` 包中必须定义一个 `main` 函数。程序从 `main` 函数开始执行。
**作用:**

- **程序入口**：程序从 `main` 函数开始执行。
- **初始化**：在 `main` 函数中进行必要的初始化工作。
- **控制流**：控制程序的主要流程和逻辑。

### init函数

`init` 函数用于初始化包。每个包可以有多个 `init` 函数，它们在 `main` 函数之前执行。`init` 函数不能被显式调用，它们在包初始化时自动执行。

**作用:**

- **包初始化**：用于在包加载时进行初始化工作。
- **设置默认值**：可以在 `init` 函数中设置一些默认值或进行配置。

**示例:**
以下是一个包含 `init` 函数的 Go 程序示例：

```go
package main

import "fmt"

func init() {
    fmt.Println("Init function called")
}

func main() {
    fmt.Println("Main function called")
}
```

在这个示例中，`init` 函数会在 `main` 函数之前执行，输出 "Init function called"。

### 多个init函数

一个包中可以有多个 `init` 函数，它们的执行顺序是按照它们在文件中的出现顺序。

```go
package main

import "fmt"

func init() {
    fmt.Println("First init function")
}

func init() {
    fmt.Println("Second init function")
}

func main() {
    fmt.Println("Main function")
}
```

输出结果将是：

```go
First init function
Second init function
Main function
```

**包的初始化顺序**
如果一个包依赖于其他包，那么这些依赖包的 `init` 函数会在当前包的 `init` 函数之前执行。

```go
// package a
package a

import "fmt"

func init() {
    fmt.Println("Init function in package a")
}

// package b
package b

import (
    "fmt"
    "a"
)

func init() {
    fmt.Println("Init function in package b")
}

// package main
package main

import (
    "fmt"
    "b"
)

func init() {
    fmt.Println("Init function in main package")
}

func main() {
    fmt.Println("Main function")
}
```

输出结果将是：

```go
Init function in package a
Init function in package b
Init function in main package
Main function
```

### Init和Main的区别

1. **作用范围不同**：  
    - `main` 函数是程序的入口点，控制整个程序的执行流程。
    - `init` 函数用于包的初始化，在包加载时自动调用。
2. **调用时机不同**：
    - `main` 函数在程序启动时调用一次。
    - `init` 函数在包加载时调用，可能调用多次（每个包的 `init` 函数都会被调用）。
3. **定义限制不同**：
    - 每个程序只能有一个 `main` 函数。
    - 每个包可以有多个 `init` 函数。
