# Scala 数组、集合函数大全

- Array
- ++
- ++:
- +:
- :+
- /:
- :\
- addString(b)
- addString(b, sep)
- aggregate
- apply
- canEqual
- charAt
- clone
- collect
- collectFirst
- combinations
- contains
- containsSlice
- copyToArray(xs)
- copyToArray(xs, start)
- copyToArray(xs, start, len)
- copyToBuffer
- corresponds
- count
- diff
- distinct
- drop
- dropRight
- dropWhile
- endsWith
- exists
- filter
- find
- flatMap
- flatten
- fold
- foldLeft
- foldRight
- forall
- foreach
- groupBy
- grouped
- hasDefiniteSize
- head
- headOption
- indexOf(elem)
- indexOf(elem, from)
- indexOfSlice(that)
- indexOfSlice(that, from)
- indexWherepp
- indexWhere(p, from)
- indices
- init
- inits
- intersect
- isDefinedAt
- isEmpty
- isTraversableAgain
- iterator
- last
- lastIndexOf(elem)
- lastIndexOf(elem, end)
- lastIndexOfSlice(that)
- lastIndexOfSlice(that, end)
- lastIndexWherepp
- lastIndexWhere(p, end)
- lastOption
- length
- lengthCompare
- map
- max
- maxBy
- min
- minBy
- mkString
- mkString(sep)
- mkString(start, sep, end)
- nonEmpty
- padTo
- par
- partition
- patch
- permutations
- prefixLength
- product
- reduce
- reduceLeft
- reduceRight
- reduceLeftOption
- reduceRightOption
- reverse
- reverseIterator
- reverseMap
- sameElements
- scan
- scanLeft
- scanRight
- segmentLength
- seq
- size
- slice
- sliding(size)
- sliding(size, step)
- sortBy
- sorted
- span
- splitAt
- startsWith(that)
- startsWith(that, offset)
- stringPrefix
- subSequence
- sum
- tail
- tails
- take
- takeRight
- takeWhile
- toArray
- toBuffer
- toIndexedSeq
- toIterable
- toIterator
- toList
- toMap
- toSeq
- toSet
- toStream
- toVector
- transpose
- union
- unzip
- unzip3
- update
- updated
- view
- withFilter
- zip
- zipAll
- zipWithIndex

# Array

数组是一种可变的、可索引的数据集合。在 Scala 中用 Array[T] 的形式来表示 Java 中的数组形式 T[]。

示例：
```
    val arr = Array(1, 2, 3, 4) // 声明一个数组对象
    val first = arr(0) // 读取第一个元素
    arr(3) = 100 // 替换第四个元素为 100
    val newarr = arr.map(_ * 2) // 所有元素乘 2
    println(newarr.mkString(",")) // 打印数组，结果为：2,4,6,200
```
 

# ++

定义：def ++[B](that: GenTraversableOnce[B]): Array[B]

描述：合并集合，并返回一个新的数组，新数组包含左右两个集合的内容

示例：
```
    val a = Array(1, 2)
    val b = Array(3, 4)
    val c = a ++ b
    println(c.mkString(",")) // 1,2,3,4
```
 

# ++:
定义：def ++:[B >: A, That](that: collection.Traversable[B])(implicit bf: CanBuildFrom[Array[T], B, That]): That

描述：这个方法同上一个方法类似，两个加号后面多了一个冒号，但是不同的是右边操纵数的类型决定着返回结果的类型

示例：Array 和 List 结合，返回结果是 List 类型
```
    val a = List(1, 2)
    val b = scala.collection.mutable.LinkedList(3, 4)
    val c = a ++: b
    println(c.getClass().getName()) // c 的类型: scala.collection.mutable.LinkedList
```
 

# +:
定义：def +:(elem: A): Array[A]

描述：在数组前面添加一个元素，并返回新的数组对象

示例：
```
    val a = List(1, 2)
    val b = 0 +: a
    println(b.mkString(",")) // 0,1,2
```
 

# :+
定义：def :+(elem: A): Array[A]

描述：在数组后面添加一个元素，并返回新的数组对象

示例：
```
    val a = List(1, 2)
    val b = a :+ 3
    println(b.mkString(",")) // 1,2,3
```
 

# /:
定义：def /:[B](z: B)(op: (B, T) ⇒ B): B

描述：对数组中所有的元素从左向右遍历，进行相同的迭代操作，foldLeft 的简写

示例：
```
    val a = List(1, 2, 3, 4)
    val b = (10 /: a) (_ + _) // (((10+1)+2)+3)+4
    val c = (10 /: a) (_ * _) // (((10*1)*2)*3)*4
    println("b: " + b) // b: 20
    println("c: " + c) // c: 240
```
 

# :\
定义：def :[B](z: B)(op: (T, B) ⇒ B): B

描述：对数组中所有的元素从右向左遍历，进行相同的迭代操作，foldRight 的简写

示例：
```
    val a = List(1, 2, 3, 4)
    val b = (a :\ 10) (_ - _) // 1-(2-(3-(4-10)))
    val c = (a :\ 10) (_ * _) // 1*(2*(3*(4*10)))
    println("b: " + b) // b: -8
    println("c: " + c) // c: 240
```
 

# addString(b)
定义：def addString(b: StringBuilder): StringBuilder

描述：将数组中的元素逐个添加到 StringBuilder 中

示例：
```
    val a = List(1, 2, 3, 4)
    val b = new StringBuilder()
    a.addString(b)
    println(b) // 1234
```
 

# addString(b, sep)
定义：def addString(b: StringBuilder, sep: String): StringBuilder

描述：将数组中的元素逐个添加到 StringBuilder 中，每个元素用 sep 分隔符分开

示例：
```
    val a = List(1, 2, 3, 4)
    val b = new StringBuilder()
    a.addString(b, ",")
    println(b) // 1,2,3,4
```

# aggregate
定义：def aggregate[B](z: ⇒ B)(seqop: (B, T) ⇒ B, combop: (B, B) ⇒ B): B

描述：聚合计算，aggregate 是柯里化方法，参数是两个方法

示例：为了方便理解，把 aggregate 的两个参数分别封装成两个方法，并把分区和不分区的计算过程分别打印出来
```
  def seqno(m: Int, n: Int): Int = {
    val s = "seq_exp = %d + %d"
    println(s.format(m, n))
    m + n
  }

  def combine(m: Int, n: Int): Int = {
    val s = "com_exp = %d + %d"
    println(s.format(m, n))
    m + n
  }
  
  def main(args: Array[String]) {
    val a = List(1, 2, 3, 4)

    val b = a.aggregate(5)(seqno, combine) // 不分区
    println("b = " + b)
    /**
     * seq_exp = 5 + 1
     * seq_exp = 6 + 2
     * seq_exp = 8 + 3
     * seq_exp = 11 + 4
     * b = 15
     */
     
    val c = a.par.aggregate(5)(seqno, combine) // 分区
    println("c = " + c)
    /**
     * seq_exp = 5 + 3
     * seq_exp = 5 + 2
     * seq_exp = 5 + 4
     * seq_exp = 5 + 1
     * com_exp = 6 + 7
     * com_exp = 8 + 9
     * com_exp = 13 +17
     * c = 30
     */
  }
```

通过上面的运算不难发现，不分区时，seqno 是把初始值顺序和每个元素相加，把得到的结果与下一个元素进行运算。

分区时，seqno 是把初始值与每个元素相加，但结果不参与下一步运算，而是放到另一个序列中，由第二个方法 combine 进行处理。

上面过程可以简写为

val b = a.aggregate(5)(_+_,_+_) // 不分区
val c = a.par.aggregate(5)(_+_,_+_) // 分区

 

apply
定义：def apply(i: Int): T

描述：获取指定索引处的元素

示例：

    val a = List(1, 2, 3, 4)
    val b = a.apply(1) // a.apply(i) 同 a(i)
    println(b) // 2

 

canEqual
定义：def canEqual(that: Any): Boolean

描述：判断两个对象是否可以进行比较

示例：基本上所有对象都可以进行比较，我不知道这个方法的意义何在

    val a = List(1, 2, 3, 4)
    val b = Array('a', 'b', 'c')
    println(a.canEqual(b)) // true

 

charAt
定义：def charAt(index: Int): Char

描述：获取 index 索引处的字符，这个方法会执行一个隐式的转换，将 Array[T] 转换为 ArrayCharSequence，只有当 T 为 Char 类型时，这个转换才会发生

示例：

    val chars = Array('a', 'b', 'c')
    println(chars.charAt(0)) // a

 

clone
定义：def clone(): Array[T]

描述：创建一个副本

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.clone()
    println(b.mkString(",")) // 1,2,3,4

 

collect
定义：def collect[B](pf: PartialFunction[A, B]): Array[B]

描述：通过执行一个并行计算（偏函数），得到一个新的数组对象

示例：通过下面的偏函数，把数组中的小写的 a 转换为大写的 A

    val fun: PartialFunction[Char, Char] = {
      case 'a' => 'A'
      case x => x
    }
    val a = Array('a', 'b', 'c')
    val b = a.collect(fun)
    println(b.mkString(",")) // A,b,c

 

collectFirst
定义：def collectFirst[B](pf: PartialFunction[T, B]): Option[B]

描述：在序列中查找第一个符合偏函数定义的元素，并执行偏函数计算

示例：定义一个偏函数，当被执行对象为 Int 类型时，进行乘 100 的操作

    val fun: PartialFunction[Any, Int] = {
      case x: Int => x * 100
    }
    val a = Array(1, 'a', "b")
    val b = arr.collectFirst(fun)
    println(b) // Some(100)

另一种写法：

    b = arr.collectFirst({ case x: Int => x * 100 })

 

combinations
定义：def combinations(n: Int): collection.Iterator[Array[T]]

描述：combinations 表示组合，这个排列组合会选出所有包含字符不一样的组合，但不考虑顺序，对于 “abc”、“cba”，视为相同组合，参数 n 表示序列长度，就是几个字符为一组

示例：

    val a = Array("a", "b", "c")
    val b = arr.combinations(2)
    b.foreach(x => println(x.mkString(",")))
    /**
     * a,b
     * a,c
     * b,c
     */

 

contains
定义：def contains[A1 >: A](elem: A1): Boolean

描述：判断序列中是否包含指定对象

示例：

    val a = List(1, 2, 3, 4)
    println(a.contains(1)) // true

 

containsSlice
定义：def containsSlice[B](that: GenSeq[B]): Boolean

描述：判断当前序列中是否包含另一个序列

示例：

    val a = List(1, 2, 3, 4)
    val b = List(2, 3)
    println(a.containsSlice(b)) // true

 

copyToArray(xs)
定义：def copyToArray(xs: Array[A]): Unit

描述：将当前数组元素复制到另一个数组中

示例：

    val a = Array(1, 2, 3)
    val b: Array[Int] = new Array(5)
    a.copyToArray(b)
    println(b.mkString(",")) // 1,2,3,0,0

 

copyToArray(xs, start)
定义：def copyToArray(xs: Array[A], start: Int): Unit

描述：将当前数组元素复制到另一个数组中，从 start 位置开始复制

示例：

    val a = Array(1, 2, 3)
    val b: Array[Int] = new Array(5)
    a.copyToArray(b, 1)
    println(b.mkString(",")) // 0,1,2,3,0

 

copyToArray(xs, start, len)
定义：def copyToArray(xs: Array[A], start: Int, len: Int): Unit

描述：将当前数组元素复制到另一个数组中，从 start 位置开始复制，长度为 len

示例：

    val a = Array(1, 2, 3)
    val b: Array[Int] = new Array(5)
    a.copyToArray(b, 1, 2)
    println(b.mkString(",")) // 0,1,2,0,0

 

copyToBuffer
定义：def copyToBuffer[B >: A](dest: Buffer[B]): Unit

描述：将数组中的元素复制到 Buffer 中

示例：

    val a = Array(1, 2, 3, 4)
    val b: ArrayBuffer[Int] = ArrayBuffer()
    a.copyToBuffer(b)
    println(b.mkString(",")) // 1,2,3,4

 

corresponds
定义：def corresponds[B](that: GenSeq[B])(p: (T, B) ⇒ Boolean): Boolean

描述：判断两个序列的长度以及对应位置元素是否符合某个条件。如果两个序列具有相同的元素数量并且 p(x, y)=true，则返回 true

示例：下面代码检查 a 和 b 长度是否相等，并且 a 中元素是否小于 b 中对应位置的元素

    val a = Array(1, 2, 3, 4)
    val b = Array(5, 6, 7, 8)
    println(a.corresponds(b)(_ < _)) // true

 

count
定义：def count(p: (T) ⇒ Boolean): Int

描述：统计符合条件的元素个数

示例：下面代码统计数组中大于 2 的元素个数

    val a = Array(1, 2, 3, 4)
    println(a.count(x => x > 2)) // 2

 

diff
定义：def diff(that: collection.Seq[T]): Array[T]

描述：计算当前数组与另一个数组的差集，即将当前数组中没有在另一个数组中出现的元素返回

示例：

    val a = Array(1, 2, 3, 4)
    val b = Array(3, 4, 5, 6)
    val c = a.diff(b)
    println(c.mkString(",")) // 1,2

 

distinct
定义：def distinct: Array[T]

描述：去除当前集合中重复的元素，只保留一个

示例：

    val a = Array(1, 2, 2, 3, 4, 4)
    val b = a.distinct
    println(b.mkString(",")) // 1,2,3,4
1
2
3
 

drop
定义：def drop(n: Int): Array[T]

描述：将当前数组中前 n 个元素去除，返回一个新数组

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.drop(2)
    println(b.mkString(",")) // 3,4
1
2
3
 

dropRight
定义：def dropRight(n: Int): Array[T]

描述：功能同 drop，去掉尾部的 n 个元素

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.dropRight(2)
    println(b.mkString(",")) // 1,2
1
2
3
 

dropWhile
定义：def dropWhile(p: (T) ⇒ Boolean): Array[T]

描述：去除当前数组中符合条件的元素，返回剩余的数组，这个需要一个条件，就是从当前数组的第一个元素起，就要满足条件，直到碰到第一个不满足条件的元素结束（即使后面还有符合条件的元素），否则返回整个数组

示例：下面去除数组 a 中大于 2 的元素，第一个元素 3 满足，它后面的元素 2 不满足，所以返回 (2,3,4)

    val a = Array(1, 2, 3, 4)
    val b = a.dropWhile(x => x < 2)
    println(b.mkString(",")) // 2,3,4
1
2
3
如果数组 a 是 (1,2,3,4)，第一个元素就不满足条件，则返回整个数组 (1,2,3,4)

    val a = Array(1, 2, 3, 4)
    val b = a.dropWhile(x => x > 2)
    println(b.mkString(",")) // 1,2,3,4
1
2
3
 

endsWith
定义：def endsWith[B](that: GenSeq[B]): Boolean

描述：判断当前序列是否以某个序列结尾

示例：

    val a = Array(1, 2, 3, 4)
    val b = Array(3, 4)
    println(a.endsWith(b)) // true
1
2
3
 

exists
定义：def exists(p: (T) ⇒ Boolean): Boolean

描述：判断当前数组是否包含符合条件的元素

示例：

    val a = Array(1, 2, 3, 4)
    println(a.exists(x => x == 3)) // true
    println(a.exists(x => x == 30)) // false
1
2
3
 

filter
定义：def filter(p: (T) ⇒ Boolean): Array[T]

描述：取得当前数组中符合条件的元素，组成新的数组返回

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.filter(x => x > 2)
    println(b.mkString(",")) // 3,4
1
2
3
 

find
定义：def find(p: (T) ⇒ Boolean): Option[T]

描述：查找第一个符合条件的元素，返回 Option

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.find(x => x > 2)
    println(b) // Some(3)
1
2
3
 

flatMap
定义：def flatMap[B](f: (A) ⇒ GenTraversableOnce[B]): Array[B]

描述：对当前序列的每个元素进行操作，结果放入新序列返回，参数要求是 GenTraversableOnce 及其子类

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.flatMap(x => 1 to x)
    println(b.mkString(","))
    /**
     * 1,1,2,1,2,3,1,2,3,4
     * 从 1 开始，分别对集合 a 中的每个元素生成一个递增序列，过程如下
     * 1
     * 1,2
     * 1,2,3
     * 1,2,3,4
     */
1
2
3
4
5
6
7
8
9
10
11
 

flatten
定义：def flatten[U](implicit asTrav: (T) ⇒ collection.Traversable[U], m: ClassTag[U]): Array[U]

描述：扁平化，将二维数组的所有元素组合在一起，形成一个一维数组返回

示例：

    val a = Array(Array(1, 2, 3), Array(4, 5, 6))
    val b = a.flatten
    println(b.mkString(",")) // 1,2,3,4,5,6
1
2
3
 

fold
定义：def fold[A1 >: A](z: A1)(op: (A1, A1) ⇒ A1): A1ClassTag[U]): Array[U]

描述：对序列中的每个元素进行二元运算，和 aggregate 有类似的语义，但执行过程有所不同

示例：

  def seqno(m: Int, n: Int): Int = {
    val s = "seq_exp = %d + %d"
    println(s.format(m, n))
    m + n
  }

  def main(args: Array[String]) {
    val a = Array(1, 2, 3, 4)
    
    val b = a.fold(5)(seqno) // 不分区
    println("b = " + b)
    /**
     * seq_exp = 5 + 1
     * seq_exp = 6 + 2
     * seq_exp = 8 + 3
     * seq_exp = 11 + 4
     * b = 15
     */
      
    val c = a.par.fold(5)(seqno) // 分区
    println("c = " + c)
    /**
     * seq_exp = 5 + 3
     * seq_exp = 5 + 2
     * seq_exp = 5 + 4
     * seq_exp = 5 + 1
     * seq_exp = 6 + 7
     * seq_exp = 8 + 9
     * seq_exp = 13 + 17
     * c = 30
     */
  }

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
 

foldLeft
定义：def foldLeft[B](z: B)(op: (B, T) ⇒ B): BClassTag[U]): Array[U]

描述：从左到右计算，简写方式：def /:[B](z: B)(op: (B, T) ⇒ B): B

示例：

  def seqno(m: Int, n: Int): Int = {
    val s = "seq_exp = %d + %d"
    println(s.format(m, n))
    m + n
  }

  def main(args: Array[String]): Unit = {
    val a = Array(1, 2, 3, 4)

    val b = a.foldLeft(5)(seqno) // 简写: (5 /: a)(_ + _)
    println("b = " + b)
    /**
     * seq_exp = 5 + 1
     * seq_exp = 6 + 2
     * seq_exp = 8 + 3
     * seq_exp = 11 + 4
     * b = 15
     */
  }

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
foldRight
定义：foldRight[B](z: B)(op: (B, T) ⇒ B): B

描述：从右到左计算，简写方式：def :[B](z: B)(op: (T, B) ⇒ B): B

示例：

  def seqno(m: Int, n: Int): Int = {
    val s = "seq_exp = %d + %d"
    println(s.format(m, n))
    m + n
  }

  def main(args: Array[String]): Unit = {
    val a = Array(1, 2, 3, 4)

    val b = a.foldRight(5)(seqno) // 简写: (a :\ 5)(_ + _)
    println("b = " + b)
    /**
     * seq_exp = 4 + 5
     * seq_exp = 3 + 9
     * seq_exp = 2 + 12
     * seq_exp = 1 + 14
     * b = 15
     */
  }

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
forall
定义：def forall(p: (T) ⇒ Boolean): Boolean

描述：检测序列中的元素是否都满足条件 p，如果序列为空，则返回 true

示例：

    val a = Array(1, 2, 3, 4)
    println(a.forall(x => x > 0)) // true
    println(a.forall(x => x > 2)) // false
1
2
3
 

foreach
定义：def foreach(f: (A) ⇒ Unit): Unit

描述：遍历序列中的元素，进行 f 操作

示例：

    val a = Array(1, 2, 3, 4)
    a.foreach(x => println(x * 10))
    /**
     * 10
     * 20
     * 30
     * 40
     */
1
2
3
4
5
6
7
8
 

groupBy
定义：def groupBy[K](f: (T) ⇒ K): Map[K, Array[T]]

描述：按条件分组，条件由 f 匹配，返回值是 Map 类型，每个 key 对应一个数组

示例：把数组中小于 3 的元素分到一组，其他元素的分到另一组，返回 Map[String, Array[Int]]

    val a = Array(1, 2, 3, 4)
    val b = a.groupBy(x => x match {
      case x if (x < 3) => "small"
      case _ => "big"
    })
    b.foreach(x => println(x._1 + ": " + x._2.mkString(",")))
    /**
     * small: 1,2
     * big: 3,4
     */
1
2
3
4
5
6
7
8
9
10
 

grouped
定义：def grouped(size: Int): collection.Iterator[Array[T]]

描述：按指定数量分组，每组有 size 个元素，返回一个迭代器

示例：

    val a = Array(1, 2, 3, 4, 5)
    val b = a.grouped(3).toList
    b.foreach(x => println("第 " + (b.indexOf(x) + 1) + " 组: " + x.mkString(",")))
    /**
     * 第 1 组: 1,2,3
     * 第 2 组: 4,5
     */
1
2
3
4
5
6
7
 

hasDefiniteSize
定义：def hasDefiniteSize: Boolean

描述：检测序列是否存在有限的长度，对应 Stream 这样的流数据则返回 false

示例：

    val a = Array(1, 2, 3, 4)
    println(a.hasDefiniteSize) // true
1
2
 

head
定义：def head: T

描述：返回序列的第一个元素，如果序列为空，将引发错误

示例：

    val a = Array(1, 2, 3, 4)
    println(a.head) // 1
1
2
 

headOption
定义：def headOption: Option[T]

描述：返回序列的第一个元素的 Option 类型对象，如果序列为空，则返回 None

示例：

    val a = Array(1, 2, 3, 4)
    println(a.headOption) // Some(1)
1
2
 

indexOf(elem)
定义：def indexOf(elem: T): Int

描述：返回元素 elem 在序列中第一次出现的索引

示例：

    val a = Array(1, 3, 2, 3, 4)
    println(a.indexOf(3)) // 1
1
2
 

indexOf(elem, from)
定义：def indexOf(elem: T, from: Int): Int

描述：返回元素 elem 在序列中第一次出现的索引，指定从索引 from 开始查找
示例：

    val a = Array(1, 3, 2, 3, 4)
    println(a.indexOf(3, 2)) // 3
1
2
 

indexOfSlice(that)
定义：def indexOfSlice[B >: A](that: GenSeq[B]): Int

描述：检测当前序列中是否包含序列 that，并返回第一次出现该序列的索引

示例：

    val a = Array(1, 2, 3, 2, 3, 4)
    val b = Array(2, 3)
    println(a.indexOfSlice(b)) // 1
1
2
3
 

indexOfSlice(that, from)
定义：def indexOfSlice[B >: A](that: GenSeq[B], from: Int): Int

描述：检测当前序列中是否包含另一个序列 that，指定从索引 from 开始查找，并返回第一次出现该序列的索引

示例：

    val a = Array(1, 2, 3, 2, 3, 4)
    val b = Array(2, 3)
    println(a.indexOfSlice(b, 2)) // 3
1
2
3
 

indexWhere(p)
定义：def indexWhere(p: (T) ⇒ Boolean): Int

描述：返回当前序列中第一个满足条件 p 的元素的索引

示例：

    val a = Array(1, 2, 3, 4)
    println(a.indexWhere(x => x > 2)) // 2
1
2
 

indexWhere(p, from)
定义：def indexWhere(p: (T) ⇒ Boolean, from: Int): Int

描述：返回当前序列中第一个满足条件 p 的元素的索引，指定从索引 from 开始查找

示例：

    val a = Array(1, 2, 3, 4)
    println(a.indexWhere(x => x > 2, 3)) // 3
1
2
 

indices
定义：def indices: collection.immutable.Range

描述：返回当前序列索引集合

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.indices
    println(b.mkString(",")) // 0,1,2,3
1
2
3
 

init
定义：def init: Array[T]

描述：返回当前序列中不包含最后一个元素的序列

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.init
    println(b.mkString(",")) // 1,2,3
1
2
3
 

inits
定义：def inits: collection.Iterator[Array[T]]

描述：对集合中的元素进行 init 迭代操作，该操作的返回值中， 第一个值是当前序列的副本，最后一个值为空，每一步都进行 init 操作，上一步的结果作为下一步的操作对象

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.inits.toList
    for (i <- 0 until b.length) {
      val s = "第 %d 个值: %s"
      println(s.format(i + 1, b(i).mkString(",")))
    }
    /**
     * 第 1 个值: 1,2,3,4
     * 第 2 个值: 1,2,3
     * 第 3 个值: 1,2
     * 第 4 个值: 1
     * 第 5 个值: 
     */
1
2
3
4
5
6
7
8
9
10
11
12
13
 

intersect
定义：def intersect(that: collection.Seq[T]): Array[T]

描述：取两个集合的交集

示例：

    val a = Array(1, 2, 3, 4)
    val b = Array(3, 4, 5, 6)
    val c = a.intersect(b)
    println(c.mkString(",")) // 3,4
1
2
3
4
 

isDefinedAt
定义：def isDefinedAt(idx: Int): Boolean

描述：判断序列中是否存在指定索引

示例：

    val a = Array(1, 2, 3, 4)
    println(a.isDefinedAt(1)) // true
    println(a.isDefinedAt(10)) // false
1
2
3
 

isEmpty
定义：def isEmpty: Boolean

描述：判断序列是否为空

示例：

    val a = Array(1, 2, 3, 4)
    val b = new Array[Int](0)
    println(a.isEmpty) // false
    println(b.isEmpty) // true
1
2
3
4
 

isTraversableAgain
定义：def isTraversableAgain: Boolean

描述：判断序列是否可以反复遍历，该方法是 GenTraversableOnce 中的方法，对于 Traversables 一般返回 true，对于 Iterators 返回 false，除非被复写

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.iterator
    println(a.isTraversableAgain) // true
    println(b.isTraversableAgain) // false
1
2
3
4
 

iterator
定义：def iterator: collection.Iterator[T]

描述：生成当前序列的迭代器

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.iterator
    println(b.mkString(",")) // 1,2,3,4
1
2
3
 

last
定义：def last: T

描述：返回序列的最后一个元素，如果序列为空，将引发错误

示例：

    val a = Array(1, 2, 3, 4)
    println(a.last) // 4
1
2
 

lastIndexOf(elem)
定义：def lastIndexOf(elem: T): Int

描述：返回元素 elem 在序列中最后一次出现的索引

示例：

    val a = Array(1, 3, 2, 3, 4)
    println(a.lastIndexOf(3)) // 3
1
2
 

lastIndexOf(elem, end)
定义：def lastIndexOf(elem: T, end: Int): Int

描述：返回元素 elem 在序列中最后一次出现的索引，指定在索引 end 之前（包括）的元素中查找

示例：

    val a = Array(1, 3, 2, 3, 4)
    println(a.lastIndexOf(3, 2)) // 1
1
2
 

lastIndexOfSlice(that)
定义：def lastIndexOfSlice[B >: A](that: GenSeq[B]): Int

描述：检测当前序列中是否包含序列 that，并返回最后一次出现该序列的索引

示例：

    val a = Array(1, 2, 3, 2, 3, 4)
    val b = Array(2, 3)
    println(a.lastIndexOfSlice(b)) // 3
1
2
3
 

lastIndexOfSlice(that, end)
定义：def lastIndexOfSlice[B >: A](that: GenSeq[B], end: Int): Int

描述：检测当前序列中是否包含序列 that，并返回最后一次出现该序列的索引，指定在索引 end 之前（包括）的元素中查找

示例：

    val a = Array(1, 2, 3, 2, 3, 4)
    val b = Array(2, 3)
    println(a.lastIndexOfSlice(b, 2)) // 1
1
2
3
 

lastIndexWhere(p)
定义：ef lastIndexWhere(p: (T) ⇒ Boolean): Int

描述：返回当前序列中最后一个满足条件 p 的元素的索引

示例：

    val a = Array(1, 2, 3, 4)
    println(a.lastIndexWhere(Int => x > 2)) // 3
1
2
 

lastIndexWhere(p, end)
定义：def lastIndexWhere(p: (T) ⇒ Boolean, end: Int): Int

描述：返回当前序列中最后一个满足条件 p 的元素的索引，指定在索引 end 之前（包括）的元素中查找

示例：

    val a = Array(1, 2, 3, 4)
    println(a.lastIndexWhere(x => x > 2, 2)) // 2
1
2
 

lastOption
定义：def lastOption: Option[T]

描述：返回序列的最后一个元素的 Option 类型对象，如果序列为空，则返回 None

示例：

    val a = Array(1, 2, 3, 4)
    println(a.lastOption) // Some(4)
1
2
 

length
定义：def length: Int

描述：返回序列元素个数

示例：

    val a = Array(1, 2, 3, 4)
    println(a.length) // 4
1
2
 

lengthCompare
定义：def lengthCompare(len: Int): Int

描述：比较序列的长度和参数 len，返回序列的长度 - len

示例：

    val a = Array(1, 2, 3, 4)
    println(a.lengthCompare(3)) // 1
    println(a.lengthCompare(4)) // 0
    println(a.lengthCompare(5)) // -1
1
2
3
4
 

map
定义：def map[B](f: (A) ⇒ B): Array[B]

描述：对序列中的元素进行 f 操作，返回生成的新序列

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.map(x => x * 10)
    println(b.mkString(",")) // 10,20,30,40
1
2
3
 

max
定义：def max: A

描述：返回序列中最大的元素

示例：

    val a = Array(1, 2, 3, 4)
    println(a.max) // 4
1
2
 

maxBy
定义：def maxBy[B](f: (A) ⇒ B): A

描述：返回序列中符合条件的第一个元素

示例：

    val a = Array(1, 2, 3, 4)
    println(a.maxBy(x => x > 2)) // 3
1
2
 

min
定义：def max: A

描述：返回序列中最小的元素

示例：

    val a = Array(1, 2, 3, 4)
    println(a.min) // 1
1
2
 

minBy
定义：def minBy[B](f: (A) ⇒ B): A

描述：返回序列中不符合条件的第一个元素

示例：

    val a = Array(1, 2, 3, 4)
    println(a.minBy(x => x < 2)) // 2
1
2
 

mkString
定义：def mkString: String

描述：将序列中所有元素拼接成一个字符串

示例：

    val a = Array(1, 2, 3, 4)
    println(a.mkString) // 1234
1
2
 

mkString(sep)
定义：def mkString: String

描述：将序列中所有元素拼接成一个字符串，以 sep 作为元素间的分隔符

示例：

    val a = Array(1, 2, 3, 4)
    println(a.mkString(",")) // 1,2,3,4
1
2
 

mkString(start, sep, end)
定义：def mkString(start: String, sep: String, end: String): String

描述：将序列中所有元素拼接成一个字符串，以 start 开头，以 sep 作为元素间的分隔符，以 end 结尾

示例：

    val a = Array(1, 2, 3, 4)
    println(a.mkString("(", ",", ")")) // (1,2,3,4)
1
2
 

nonEmpty
定义：def nonEmpty: Boolean

描述：判断序列是否不为空

示例：

    val a = Array(1, 2, 3, 4)
    val b = new Array[Int](0)
    println(a.nonEmpty) // true
    println(b.nonEmpty) // false
1
2
3
4
 

padTo
定义：def padTo(len: Int, elem: A): Array[A]

描述：填充序列，如果当前序列长度小于 len，那么新产生的序列长度是 len，多出的几个位值填充 elem，如果当前序列大于等于 len ，则返回当前序列

示例：填充一个长度为 7 的序列，不足位补 8

    val a = Array(1, 2, 3, 4)
    val b = a.padTo(7, 8)
    println(b.mkString(",")) // 1,2,3,4,8,8,8
1
2
3
 

par
定义：def par: ParArray[T]

描述：返回一个并行实现，产生的并行序列不能被修改

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.par
    println(b.mkString(",")) // 1,2,3,4
1
2
3
 

partition
定义：def partition(p: (T) ⇒ Boolean): (Array[T], Array[T])

描述：按条件将序列拆分成两个数组，满足条件的放到第一个数组，其余的放到第二个数组，返回的是包含这两个数组的元组

示例：下面以序列元素是否是偶数来拆分

    val a = Array(1, 2, 3, 4)
    val b: (Array[Int], Array[Int]) = a.partition(x => x % 2 == 0)
    println("偶数: " + b._1.mkString(",")) // 偶数: 2,4
    println("奇数: " + b._2.mkString(",")) // 奇数: 1,3
1
2
3
4
 

patch
定义：def patch(from: Int, that: GenSeq[A], replaced: Int): Array[A]

描述：批量替换，从原序列的 from 处开始，后面的 replaced 个元素，将被替换成序列 that

示例：从 a 的第二个元素开始，取两个元素，即 2 和 3 ，将这两个元素替换为序列 b

    val a = Array(1, 2, 3, 4)
    val b = Array(7, 8, 9)
    val c = a.patch(1, b, 2)
    println(c.mkString(",")) // 1,7,8,9,4
1
2
3
4
 

permutations
定义：def permutations: collection.Iterator[Array[T]]

描述：permutations 表示排列，这个排列组合会选出所有排列顺序不同的字符组合，permutations 与 combinations 不同的是，相同的组合考虑排列，对于 “abc”、“cba”，视为不同的组合

示例：

    val a = Array("a", "b", "c")
    val b = a.permutations.toList
    b.foreach( x => println(x.mkString(",")))
    /**
     * a,b,c
     * a,c,b
     * b,a,c
     * b,c,a
     * c,a,b
     * c,b,a
     */
1
2
3
4
5
6
7
8
9
10
11
 

prefixLength
定义：def prefixLength(p: (T) ⇒ Boolean): Int

描述：给定一个条件 p，返回一个前置数列的长度，这个数列中的元素都满足 p

示例：

    val a = Array(1, 2, 3, 4)
    println(a.prefixLength(x => x < 3)) // 2
1
2
 

product
定义：def product: A

描述：返回所有元素乘积的值

示例：

    val a = Array(1, 2, 3, 4)
    println(a.product) // 1*2*3*4=24
1
2
 

reduce
定义：def reduce[A1 >: A](op: (A1, A1) ⇒ A1): A1

描述：同 fold，不需要初始值

示例：

  def seqno(m: Int, n: Int): Int = {
    val s = "seq_exp = %d + %d"
    println(s.format(m, n))
    m + n
  }

  def main(args: Array[String]) {
    val a = Array(1, 2, 3, 4)
    val b = a.reduce(seqno)
    println("b = " + b)
    /**
     * seq_exp = 1 + 2
     * seq_exp = 3 + 3
     * seq_exp = 6 + 4
     * b = 10
     */
  }

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
 

reduceLeft
定义：def reduceLeft[B >: A](op: (B, T) ⇒ B): B

描述：同 foldLeft，从左向右计算，不需要初始值

示例：

  def seqno(m: Int, n: Int): Int = {
    val s = "seq_exp = %d + %d"
    println(s.format(m, n))
    m + n
  }

  def main(args: Array[String]) {
    val a = Array(1, 2, 3, 4)
    val b = a.reduceLeft(seqno)
    println("b = " + b)
    /**
     * seq_exp = 1 + 2
     * seq_exp = 3 + 3
     * seq_exp = 6 + 4
     * b = 10
     */
  }

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
 

reduceRight
定义：def reduceRight[B >: A](op: (B, T) ⇒ B): B

描述：同 foldRight，从右向左计算，不需要初始值

示例：

  def seqno(m: Int, n: Int): Int = {
    val s = "seq_exp = %d + %d"
    println(s.format(m, n))
    m + n
  }

  def main(args: Array[String]) {
    val a = Array(1, 2, 3, 4)
    val b = a.reduceRight(seqno)
    println("b = " + b)
    /**
     * seq_exp = 3 + 4
     * seq_exp = 2 + 7
     * seq_exp = 1 + 9
     * b = 10
     */
  }

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
 

reduceLeftOption
定义：def reduceLeftOption[B >: A](op: (B, T) ⇒ B): Option[B]

描述：同 reduceLeft，返回 Option

示例：

  def seqno(m: Int, n: Int): Int = {
    val s = "seq_exp = %d + %d"
    println(s.format(m, n))
    m + n
  }

  def main(args: Array[String]) {
    val a = Array(1, 2, 3, 4)
    val b = a.reduceLeftOption(seqno)
    println("b = " + b)
    /**
     * seq_exp = 1 + 2
     * seq_exp = 3 + 3
     * seq_exp = 6 + 4
     * b = Some(10)
     */
  }

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
 

reduceRightOption
定义：def reduceRightOption[B >: A](op: (T, B) ⇒ B): Option[B]

描述：同 reduceRight，返回 Option

示例：

  def seqno(m: Int, n: Int): Int = {
    val s = "seq_exp = %d + %d"
    println(s.format(m, n))
    m + n
  }

  def main(args: Array[String]) {
    val a = Array(1, 2, 3, 4)
    val b = a.reduceRightOption(seqno)
    println("b = " + b)
    /**
     * seq_exp = 3 + 4
     * seq_exp = 2 + 7
     * seq_exp = 1 + 9
     * b = Some(10)
     */
  }

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
 

reverse
定义：def reverse: Array[T]

描述：反转序列

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.reverse
    println(b.mkString(",")) // 4,3,2,1
1
2
3
 

reverseIterator
定义：def reverseIterator: collection.Iterator[T]

描述：生成反向迭代器

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.reverseIterator
    b.foreach(x => print(x + " ")) // 4 3 2 1
1
2
3
 

reverseMap
定义：def reverseMap[B](f: (A) ⇒ B): Array[B]

描述：同 map，方向相反

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.reverseMap(x => x * 10)
    println(b.mkString(",")) // 40,30,20,10
1
2
3
 

sameElements
定义：def sameElements(that: GenIterable[A]): Boolean

描述：判断两个序列是否顺序和对应位置上的元素都一样

示例：

    val a = Array(1, 2, 3, 4)

    val b = Array(1, 2, 3, 4)
    println(a.sameElements(b)) // true

    val c = Array(1, 3, 2, 4)
    println(a.sameElements(c)) // false
1
2
3
4
5
6
7
 

scan
定义：def scan[B >: A, That](z: B)(op: (B, B) ⇒ B)(implicit cbf: CanBuildFrom[Array[T], B, That]): That

描述：同 fold，scan 会把每一步的计算结果放到一个新的集合中返回，而 fold 返回的是最后的结果

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.scan(5)(_ + _)
    println(b.mkString(",")) // 5,6,8,11,15
1
2
3
 

scanLeft
定义：def scanLeft[B, That](z: B)(op: (B, T) ⇒ B)(implicit bf: CanBuildFrom[Array[T], B, That]): That

描述：同 foldLeft，从左向右计算，每一步的计算结果放到一个新的集合中返回

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.scanLeft(5)(_ + _)
    println(b.mkString(",")) // 5,6,8,11,15
1
2
3
 

scanRight
定义：def scanRight[B, That](z: B)(op: (T, B) ⇒ B)(implicit bf: CanBuildFrom[Array[T], B, That]): That

描述：同 foldRight，从右向左计算，每一步的计算结果放到（从右向左放）一个新的集合中返回

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.scanRight(5)(_ + _)
    println(b.mkString(",")) // 15,14,12,9,5
1
2
3
 

segmentLength
定义：def segmentLength(p: (T) ⇒ Boolean, from: Int): Int

描述：从序列的 from 开始向后查找，返回满足条件 p 的连续元素的长度，只返回第一个

示例：

    val a = Array(1, 2, 3, 1, 1, 1, 4)
    println(a.segmentLength(x => x < 3, 3)) // 3
1
2
 

seq
定义：def seq: collection.mutable.IndexedSeq[T]

描述：产生一个引用当前序列的 sequential 视图

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.seq
    println(b.mkString(",")) // 1,2,3,4
1
2
3
 

size
定义：def size: Int

描述：返回序列元素个数，同 length

示例：

    val a = Array(1, 2, 3, 4)
    println(a.size) // 4
1
2
 

slice
定义：def slice(from: Int, until: Int): Array[T]

描述：返回当前序列中从 from 到 until 之间的序列，不包括 until 处的元素

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.slice(1, 3)
    println(b.mkString(",")) // 2,3
1
2
3
 

sliding(size)
定义：def sliding(size: Int): collection.Iterator[Array[T]]

描述：滑动，从第一个元素开始，每个元素和它后面的 size - 1 个元素组成一个数组，最终组成一个新的集合返回，当剩余元素个数不够 size 时，则结束

示例：

    val a = Array(1, 2, 3, 4, 5)
    val b = a.sliding(3).toList
    for (i <- 0 to b.length - 1) {
      val s = "第 %d 组: %s"
      println(s.format(i + 1, b(i).mkString(",")))
    }
    /**
     * 第 1 组: 1,2,3
     * 第 2 组: 2,3,4
     * 第 3 组: 3,4,5
     */
1
2
3
4
5
6
7
8
9
10
11
 

sliding(size, step)
定义：def sliding(size: Int): collection.Iterator[Array[T]]

描述：从第一个元素开始，每个元素和它后面的 size - 1 个元素组成一个数组，最终组成一个新的集合返回，当剩余元素个数不够 size 时，则结束。该方法可以设置步长 step，每一组元素组合完后，下一组从上一组起始元素位置 + step 后的位置处开始

示例：下面代码，第一组从 1 开始， 第二组从 3 开始，因为步长是 2

    val a = Array(1, 2, 3, 4, 5)
    val b = a.sliding(3, 2).toList
    for (i <- 0 to b.length - 1) {
      val s = "第 %d 组: %s"
      println(s.format(i + 1, b(i).mkString(",")))
    }
    /**
     * 第 1 组: 1,2,3
     * 第 2 组: 3,4,5
     */
1
2
3
4
5
6
7
8
9
10
 

sortBy
定义：def sortBy[B](f: (T) ⇒ B)(implicit ord: math.Ordering[B]): Array[T]

描述：按指定的排序规则对序列排序

示例：

    val a = Array(3, 2, 1, 4)

    val b = a.sortBy(x => x) // 按 x 从小到大，即对原序列升序排列
    println("升序: " + b.mkString(",")) // 1,2,3,4

    val c = a.sortBy(x => 0 - x) // 按 -x 从小到大，即对原序列降序排列
    println("降序: " + c.mkString(",")) // 4,3,2,1
1
2
3
4
5
6
7
 

sorted
定义：def sorted[B >: A](implicit ord: math.Ordering[B]): Array[T]]

描述：使用默认的排序规则对序列排序

示例：

    val a = Array(3, 2, 1, 4)
    val b = a.sorted // 默认升序排列
    println(b.mkString(",")) // 1,2,3,4
1
2
3
 

span
定义：def span(p: (T) ⇒ Boolean): (Array[T], Array[T])

描述：将序列拆分成两个数组，从第一个元素开始，直到第一个不满足条件的元素为止，其中的元素放到第一个数组，其余的放到第二个数组，返回的是包含这两个数组的元组

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.span(x => x < 3)
    println(b._1.mkString(",")) // 1,2
    println(b._2.mkString(",")) // 3,4
1
2
3
4
 

splitAt
定义：def splitAt(n: Int): (Array[T], Array[T])

描述：从指定位置开始，把序列拆分成两个数组

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.splitAt(2)
    println(b._1.mkString(",")) //  1,2
    println(b._2.mkString(",")) //  3,4
1
2
3
4
 

startsWith(that)
定义：def startsWith[B](that: GenSeq[B]): Boolean

描述：判断序列是否以某个序列开始

示例：

    val a = Array(1, 2, 3, 4)
    val b = Array(1, 2)
    println(a.startsWith(b)) // true
1
2
3
 

startsWith(that, offset)
定义：def startsWith[B](that: GenSeq[B], offset: Int): Boolean

描述：判断序列从指定偏移处是否以某个序列开始

示例：

    val a = Array(1, 2, 3, 4)
    val b = Array(2, 3)
    println(a.startsWith(b, 1)) // true
1
2
3
 

stringPrefix
定义：def stringPrefix: String

描述：返回 toString 结果的前缀

示例：

    val a = Array(1, 2, 3, 4)
    println(a.toString()) // [I@3ab39c39
    println(a.stringPrefix) // [I
1
2
3
 

subSequence
定义：def subSequence(start: Int, end: Int): CharSequence

描述：返回 start 和 end 间的字符序列，不包含 end 处的元素

示例：

    val a = Array('a', 'b', 'c', 'd')
    val b = a.subSequence(1, 3)
    println(b.toString) // bc
1
2
3
 

sum
定义：def sum: A

描述：序列求和，元素需为 Numeric[T] 类型

示例：

    val a = Array(1, 2, 3, 4)
    println(a.sum) // 10
1
2
 

tail
定义：def tail: Array[T]

描述：返回当前序列中不包含第一个元素的序列

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.tail
    println(b.mkString(",")) // 2,3,4
1
2
3
 

tails
定义：def tails: collection.Iterator[Array[T]]

描述：同 inits，每一步都进行 tail 操作

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.tails.toList
    for (i <- 0 until b.length) {
      val s = "第 %d 个值: %s"
      println(s.format(i + 1, b(i).mkString(",")))
    }
    /**
     * 第 1 个值: 1,2,3,4
     * 第 2 个值: 2,3,4
     * 第 3 个值: 3,4
     * 第 4 个值: 4
     * 第 5 个值: 
     */
1
2
3
4
5
6
7
8
9
10
11
12
13
 

take
定义：def take(n: Int): Array[T]

描述：返回当前序列中，前 n 个元素组成的序列

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.take(3)
    println(b.mkString(",")) // 1,2,3
1
2
3
 

takeRight
定义：def takeRight(n: Int): Array[T]

描述：返回当前序列中，从右边开始，后 n 个元素组成的序列

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.takeRight(3)
    println(b.mkString(",")) // 2,3,4
1
2
3
 

takeWhile
定义：def takeWhile(p: (T) ⇒ Boolean): Array[T]

描述：返回当前序列中，从第一个元素开始，满足条件的连续元素组成的序列

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.takeWhile(x => x < 3)
    print(b.mkString(",")) // 1,2
1
2
3
 

toArray
定义：def toArray: Array[A]

描述：将序列转换成 Array 类型
 

toBuffer
定义：def toBuffer[A1 >: A]: Buffer[A1]

描述：将序列转换成 Buffer 类型
 

toIndexedSeq
定义：def toIndexedSeq: collection.immutable.IndexedSeq[T]

描述：将序列转换成 IndexedSeq 类型
 

toIterable
定义：def toIterable: collection.Iterable[T]

描述：将序列转换成可迭代的类型
 

toIterator
定义：def toIterator: collection.Iterator[T]

描述：将序列转换成迭代器，同 iterator 方法
 

toList
定义：def toList: List[T]

描述：将序列转换成 List 类型
 

toMap
定义：def toMap[T, U]: Map[T, U]

描述：将序列转转换成 Map 类型，需要被转化序列中包含的元素是 Tuple2 类型
 

toSeq
定义：def toSeq: collection.Seq[T]

描述：将序列转换成 Seq 类型
 

toSet
定义：def toSet[B >: A]: Set[B]

描述：将序列转换成 Set 类型
 

toStream
定义：def toStream: collection.immutable.Stream[T]

描述：将序列转换成 Stream 类型
 

toVector
定义：def toVector: Vector[T]

描述：将序列转换成 Vector 类型
 

transpose
定义：def transpose[U](implicit asArray: (T) ⇒ Array[U]): Array[Array[U]]

描述：矩阵转置，二维数组行列转换

示例：

    val a = Array(Array("a", "b"), Array("c", "d"), Array("e", "f"))
    val b = a.transpose
    b.foreach(x => println((x.mkString(","))))
    /**
     * a,c,e
     * b,d,f
     */
1
2
3
4
5
6
7
 

union
定义：def union(that: collection.Seq[T]): Array[T]

描述：合并两个序列，同操作符 ++

示例：

    val a = Array(1, 2)
    val b = Array(3, 4)
    val c = a.union(b)
    println(c.mkString(",")) // 1,2,3,4
1
2
3
4
 

unzip
定义：def unzip[T1, T2](implicit asPair: (T) ⇒ (T1, T2), ct1: ClassTag[T1], ct2: ClassTag[T2]): (Array[T1], Array[T2])

描述：将含有两个二元组的数组，每个元组的第一个元素组成一个数组，第二个元素组成一个数组，返回包含这两个数组的元组

示例：

    val chars = Array(("a", "b"), ("c", "d"))
    val b = chars.unzip
    println(b._1.mkString(",")) // a,c
    println(b._2.mkString(",")) // b,d
1
2
3
4
 

unzip3
定义：def unzip3[T1, T2, T3](implicit asTriple: (T) ⇒ (T1, T2, T3), ct1: ClassTag[T1], ct2: ClassTag[T2], ct3: ClassTag[T3]): (Array[T1], Array[T2], Array[T3])

描述：将含有三个三元组的数组，每个元组的第一个元素组成一个数组，第二个元素组成一个数组，第三个元素组成一个数组，返回包含这三个数组的元组

示例：

    val chars = Array(("a", "b", "x"), ("c", "d", "y"), ("e", "f", "z"))
    val b = chars.unzip3
    println(b._1.mkString(",")) // a,c,e
    println(b._2.mkString(",")) // b,d,f
    println(b._3.mkString(",")) // x,y,z
1
2
3
4
5
 

update
定义：def update(i: Int, x: T): Unit

描述：将序列中 i 索引处的元素更新为 x

示例：

    val a = Array(1, 2, 3, 4)
    a.update(1, 7)
    println(a.mkString(",")) //1,7,3,4
1
2
3
 

updated
定义：def updated(index: Int, elem: A): Array[A]

描述：将序列中 i 索引处的元素更新为 x，并返回替换后的数组

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.updated(1, 7)
    println(b.mkString(",")) //1,7,3,4
1
2
3
 

view
定义：def view(from: Int, until: Int): IndexedSeqView[T, Array[T]]

描述：返回当前序列中从 from 到 until 之间的序列，不包括 until 处的元素

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.view(1, 3)
    println(b.mkString(",")) // 2,3
1
2
3
 

withFilter
定义：def withFilter(p: (T) ⇒ Boolean): FilterMonadic[T, Array[T]]

描述：根据条件 p 过滤元素

示例：

    val a = Array(1, 2, 3, 4)
    val b = a.withFilter(x => x > 2).map(x => x)
    println(b.mkString(",")) // 3,4
1
2
3
 
 

zip
定义：def zip[B](that: GenIterable[B]): Array[(A, B)]

描述：将两个序列对应位置上的元素组成一个元组数组，要求两个序列长度相同

示例：

    val a = Array(1, 2, 3, 4)
    val b = Array(4, 3, 2, 1)
    val c = a.zip(b)
    println(c.mkString(",")) // (1,4),(2,3),(3,2),(4,1)
1
2
3
4
 

zipAll
定义：def zipAll[B](that: collection.Iterable[B], thisElem: A, thatElem: B): Array[(A, B)]

描述：同 zip ，但是允许两个序列长度不同，不足的自动填充，如果当前序列短，不足的元素填充为 thisElem，如果 that 序列短，填充为 thatElem

示例：

    val a = Array(1, 2, 3, 4, 5, 6, 7)
    val b = Array(5, 4, 3, 2, 1)
    val c = a.zipAll(b, 8, 9) // (1,5),(2,4),(3,3),(4,2),(5,1),(6,9),(7,9)
    println(c.mkString(","))

    val x = Array(1, 2, 3, 4)
    val y = Array(6, 5, 4, 3, 2, 1)
    val z = x.zipAll(y, 8, 9) // (1,6),(2,5),(3,4),(4,3),(8,2),(8,1)
    println(z.mkString(","))
1
2
3
4
5
6
7
8
9
 

zipWithIndex
定义：def zipWithIndex: Array[(A, Int)]

描述：序列中的每个元素和它的索引组成一个元组数组

示例：

    val a = Array('a', 'b', 'c', 'd')
    val b = a.zipWithIndex
    println(b.mkString(",")) // (a,0),(b,1),(c,2),(d,3)
