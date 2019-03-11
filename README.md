# GPPageView
#### 仿简书、微博个人主页多页面滑动视图。

##### 思路：
- 大多数人使用CollectionView的Cell再嵌套VC的思路去实现，这样的结构过于臃肿。从一般性角度出发，分页使用ScrollView，列表使用tableView，即可完成我们想要的效果。
- 我这里用了这样的思路：页面底部是一个 UIScrollView; 接着 UIScrollView上面add了三个UITableView；headView和Segment放在View上，不能够放在scrollView或者成为tableView的HeaderView，监听tableView的滚动，改变HeaderView和segemnt的坐标，记录每次tableView的滚动距离,切页面的时候使得HeaderView和Segment的位置和上一次保持一致。接着挨个实现其功能即可。
  
##### 效果图

![效果图](https://github.com/cocoa-ziyue/GPPageView/blob/master/Jietu20190311-134542-HD.gif)


##### 关于作者
- 博客地址 https://www.jianshu.com/u/f0b11432b297 ,如有疑问或有建议的地方，欢迎讨论。
- iOS开发QQ群:674228487

### License

This repositorie is released under the under [MIT License](https://github.com/liuzhongning/NNJaneBookView/blob/master/LICENSE)
