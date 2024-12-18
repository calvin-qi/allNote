# linux三剑客sed,awk,grep

## sed

### sed语法

```shell
sed [options] 'command' file(s)
sed [options] -f scriptfile file(s)
```

选项

| 参数      | 完整参数            | 说明                                           |
| --------- | ------------------- | ---------------------------------------------- |
| -e script | --expression=script | 以选项中的指定的script来处理输入的文本文件     |
| -f script | --files=script      | 以选项中的指定的script文件来处理输入的文本文件 |
| -h        | --help              | 显示帮助                                       |
| -n        | --quiet --silent    | 仅显示script处理后的结果                       |
| -V        | --version           | 显示版本信息                                   |

sed命令

| 命令    | 说明                                                         |
| ------- | ------------------------------------------------------------ |
| d       | 删除，删除选择的行                                           |
| D       | 删除模板块的第一行                                           |
| s       | 替换指定字符                                                 |
| h       | 拷贝模板块的内容到内存中的缓冲区                             |
| H       | 追加模板块的内容到内存中的缓冲区                             |
| g       | 获得内存缓冲区的内容，并替代当前模板块中文本                 |
| G       | 获得内存缓冲区的内容，并追加到当前模板块文本的后面           |
| l       | 列表不能打印字符的清单                                       |
| n       | 读取下一个输入行，用下一个命令处理新的行而不是第一个命令     |
| N       | 追加下一个输入行到模板块后面并在二者间嵌入一个新行，改变当前行号码 |
| p       | 打印模板块的行                                               |
| P       | 打印模板块的第一行                                           |
| q       | 退出sed                                                      |
| b label | 分支到脚本中带有标记的地方，如果分支不存在则分支到脚本的末尾 |
| r file  | 从file中读行                                                 |
| t label | if分支，从最后一行开始，条件一旦满足或者T，t命令，将导致分支到带有标号的命令处，或者到脚本的末尾 |
| T label | 错误分支，从最后一行开始，一旦发生错误或者T，t命令，将导致分支到带有标号的命令处，或者到脚本的末尾 |
| w file  | 写并追加模板块到file末尾                                     |
| W file  | 写并追加模板块的第一行到file末尾                             |
| !       | 表示后面的命令对所有没有被选定的行发生作用                   |
| =       | 打印当前行号                                                 |
| #       | 把注释扩展到第一个换行符以前                                 |

sed替换标记

| 命令 | 说明                                                   |
| ---- | ------------------------------------------------------ |
| g    | 表示行内全面替换                                       |
| p    | 表示打印行                                             |
| w    | 表示把行写入一个文件                                   |
| x    | 表示互换模板块中的文本和缓冲区中的文本                 |
| y    | 表示把一个字符翻译为另外的字符（但是不用于正则表达式） |
| \1   | 子串匹配标记                                           |
| &    | 已匹配字符串标记                                       |

sed元字符集

| 命令   | 说明                                                         |
| ------ | ------------------------------------------------------------ |
| ^      | 匹配行开始，如：/^sed/匹配所有以sed开头的行。                |
| $      | 匹配行结束，如：/sed$/匹配所有以sed结尾的行。                |
| .      | 匹配一个非换行符的任意字符，如：/s.d/匹配s后接一个任意字符，最后是d。 |
| *      | 匹配0个或多个字符，如：/*sed/匹配所有模板是一个或多个空格后紧跟sed的行。 |
| []     | 匹配一个指定范围内的字符，如/[sS]ed/匹配sed和Sed。           |
| [^]    | 匹配一个不在指定范围内的字符，如：/[^A-RT-Z]ed/匹配不包含A-R和T-Z的一个字母开头，紧跟ed的行。 |
| (..)   | 匹配子串，保存匹配的字符，如s/(love)able/\1rs，loveable被替换成lovers。 |
| &      | 保存搜索字符用来替换其他字符，如s/love/**&**/，love这成**love**。 |
| <      | 匹配单词的开始，如:/<love/匹配包含以love开头的单词的行。     |
| \ >    | 匹配单词的结束，如/love>/匹配包含以love结尾的单词的行。      |
| x{m}   | 重复字符x，m次，如：/0{5}/匹配包含5个0的行。                 |
| x{m,}  | 重复字符x，至少m次，如：/0{5,}/匹配至少有5个0的行。          |
| x{m,n} | 重复字符x，至少m次，不多于n次，如：/0{5,10}/匹配5~10个0的行。 |

### sed用法举例

#### 替换操作：s命令

把文本中所有的`This`替换成`aaa`,只是打印出结果并不会更改文件内容

```shell
sed 's/This/aaa/' test.txt
```

-n选项和p命令一起使用表示只打印那些发生替换的行：

```shell
sed -n 's/This/aaa/p' test.txt
```

对文件进行编辑加选项`-i`，会匹配test.txt文件中每一行的第一个This替换为this:

```shell
sed -i 's/This/this/' test.txt
```

----------------------

#### 全面替换标记g

使用后缀`/g`标记会替换每一行中的所有匹配：

```shell
sed 's/this/This/g' test.txt
```

当需要从第`N`处匹配开始替换时，可以使用`/Ng`

```shell
echo sksksksksksk | sed 's/sk/SK/2g'
#skSKSKSKSKSK
```

以上命令中字符 `/`在`sed`中作为定界符使用，也可以使用任意的定界符：比如`echo sksksksksksk | sed 's:sk:SK:4g'`

------------------

#### 定界符

定界符出现在样式内部时，需要进行转义：

```shell
echo '/usr/local/bin' | sed 's/\/usr\/local\/bin/\/USR\/LOCAL\/BIN/g'
#/USR/LOCAL/BIN
```

----

#### 删除操作：d命令

删除空白行：

```shell
sed '/^$/d' test.txt
```

删除文件的第2行：

```shell
sed '2d' test.txt
```

删除文件的第2行到末尾所有行：

```shell
sed '2,$d' test.txt
```

删除文件最后一行：

```shell
sed '$d' test.txt
```

删除文件中所有以my开头的行：

```shell
sed '/^my/'d test.txt
```

---

#### 已匹配字符串标记&

正则表达式`\w\+`匹配每一个单词，使用`[&]`替换它，&对应之前所匹配到的单词：

```shell
echo this is a test line | sed 's/\w\+/[&]/g'
#[this] [is] [a] [test] [line]
```

---

#### 子串匹配标记\1

匹配给定样式的其中一部份：

```shell
echo this is digit 7 in a number | sed 's/digit \([0-9]\)/\1/'
#this is 7 in a number
#命令中digit 7，被替换成7.样式匹配到的子串是7，\(..\)用于匹配子串，对于匹配到的第一个子串标记为\1，依此类推匹配到的第二个结果就是\2
echo aaa BBB | sed 's/\([a-z]\+\) \([A-Z]\+\)/\2 \1/'
#BBB aaa
```

---

#### 组合多个表达式

```shell
sed '表达式' | sed '表达式'

等价于

sed '表达式; 表达式'
```

-------------------

#### 引用

sed表达式可以使用单引号来引用，但是如果表达式内部包含变量字符串，就需要使用双引号。

```shell
test=hello
echo hello WORLD | sed "s/$test/HELLO/"
#HELLO WORLD
```

---------------

#### 选定行的范围：,(逗号)

打印从第5行开始到第一个包含以this开始的行之间的所有行：

```shell
sed -n '5,/^this/p' test.txt
#my fish's name is this george
#this is your goat
```

----------------

#### 多点编辑：e命令

-e选项允许在同一行里执行多条命令：

```shell
sed -e '1,5d' -e 's/my/MY/' test.txt
#this is your goat
#MY goat's name is this adam
##上面sed表达式的第一条命令删除1至5行，第二条命令用check替换test。命令的执行顺序对结果有影响。如果两个命令都是替换命令，那么第一个命令将影响第二个命令的结果。

和 -e 等价的命令是 --expression
```

----------------

#### 从文件读入：r命令

file里的内容被读进来，显示在与test匹配的行后面，如果匹配多行，则file的内容将显示在所有匹配行的下面：

```shell
cat test1.txt
#aaaaaaaa
sed '/my/r test1.txt' test.txt
#my cat's name is betty
#aaaaaaaa
#this is your this dog
#my dog's name is this frank
#aaaaaaaa
```

-----

#### 写入文件：w命令

在test.txt中所有包含my的行都被写入test2.txt里：

```shell
sed -n '/my/w test2.txt' test.txt
cat test2.txt
#my cat's name is betty
#my dog's name is this frank
#my fish's name is this george
#my goat's name is this adam
```

----------------

#### 追加（行下）：a\命令

将this is a test line 追加到以my开头的行后面：

```shell
sed '/^my/a\this is a test line' test.txt
#my cat's name is betty
#this is a test line
```

在text.txt文件第2行之后插入this is a test line:

```shell
sed '2a\this is a test line' test.txt
#my cat's name is betty
#this is your this dog
#this is a test line
```

---

#### 插入（行上）：i\命令

将this is a test line 插入到以my开头的行前面：

```shell
sed '/^my/i\this is a test line' test.txt
#this is a test line
#my cat's name is betty
```

---

#### 下一个：n命令

如果my被匹配，则移动到匹配行的下一行，替换这一行的this为This,并打印该行：

```shell
sed '/my/{n; s/this/This/; }' test.txt
#my cat's name is betty
#This is your this dog
```

#### 变形：y命令

把1-10行内所有的abcde转变为大写，注意，正则表达式元字符不能使用这个命令：

```shell
sed '1,10y/abcde/ABCDE/' test.txt
#my CAt's nAmE is BEtty
#this is your this Dog
```

#### 退出：q命令

打印完第3行，退出sed

```shell
sed '3q' test.txt
#my cat's name is betty
#this is your this dog
#my dog's name is this frank
```

#### 打印奇数行或偶数行

方法1：

```shell
#奇数行
sed -n 'p;n' test.txt
#偶数行
sed -n 'n;p' test.txt
```

方法2：

```shell
sed -n '1~2p' test.txt
sed -n '2~2p' test.txt
```
