```dart
/// xpath
/// //div[@id='mmComponent_images_1']//li//a/@m
/// m 里面的murl 是真实地址
/// bing 必应 
/**
    https://cn.bing.com/images/async?q=壁纸&first=150&count=35&cw=1536&ch=508&relp=35&apc=0&tsc=ImageHoverTitle&datsrc=I&layout=RowBased_Landscape&mmasync=1&dgState=x*217_y*1143_h*185_c*1_i*141_r*27&IG=94E3F74998EC439189A734BFF7A1B44C&SFX=5&iid=images.5556

    del &iid=images.5556  结果会稍有不同，但是数量不变，可能是bing手机我们个人的特性ID
    https://cn.bing.com/images/async?q=壁纸&first=150&count=35&cw=1536&ch=508&relp=35&apc=0&tsc=ImageHoverTitle&datsrc=I&layout=RowBased_Landscape&mmasync=1&dgState=x*217_y*1143_h*185_c*1_i*141_r*27&IG=94E3F74998EC439189A734BFF7A1B44C&SFX=5

    del &SFX=5    结果会稍有不同，但是数量不变，
    https://cn.bing.com/images/async?q=壁纸&first=150&count=35&cw=1536&ch=508&relp=35&apc=0&tsc=ImageHoverTitle&datsrc=I&layout=RowBased_Landscape&mmasync=1&dgState=x*217_y*1143_h*185_c*1_i*141_r*27&IG=94E3F74998EC439189A734BFF7A1B44C
    https://cn.bing.com/images/async?q=壁纸&first=150&count=35&cw=1536&ch=508&relp=35&apc=0&tsc=ImageHoverTitle&datsrc=I&layout=RowBased_Landscape&mmasync=1&dgState=x*217_y*1143_h*185_c*1_i*141_r*27
    del &IG=94E3F74998EC439189A734BFF7A1B44C
    https://cn.bing.com/images/async?q=壁纸&first=150&count=35&cw=1536&ch=508&relp=35&apc=0&tsc=ImageHoverTitle&datsrc=I&layout=RowBased_Landscape&mmasync=1
    del &dgState=x*217_y*1143_h*185_c*1_i*141_r*27 返回的图片不展示了，应该是没有了src地址
    https://cn.bing.com/images/async?q=壁纸&first=150&count=35&cw=1536&ch=508&relp=35&apc=0&tsc=ImageHoverTitle&datsrc=I&layout=RowBased_Landscape
    del &mmasync=1 删除之后没有排版，不按照之前的style来排列了
    https://cn.bing.com/images/async?q=壁纸&first=150&count=35&cw=1536&ch=508&relp=35&apc=0&tsc=ImageHoverTitle&datsrc=I
    del &layout=RowBased_Landscape
    https://cn.bing.com/images/async?q=壁纸&first=150&count=35&cw=1536&ch=508&relp=35&apc=0&tsc=ImageHoverTitle
    del &datsrc=I
    https://cn.bing.com/images/async?q=壁纸&first=150&count=35&cw=1536&ch=508&relp=35&apc=0
    del &tsc=ImageHoverTitle
    https://cn.bing.com/images/async?q=壁纸&first=150&count=35&cw=1536&ch=508&relp=35
    del &apc=0  变化比较大，但是还是35张
    https://cn.bing.com/images/async?q=壁纸&first=150&count=35&cw=1536&ch=508
    del &relp=35  结果和上个基本一致
    https://cn.bing.com/images/async?q=壁纸&first=150&count=35
    del &cw=1080&ch=100 这个应该是做电脑屏幕适应的，方便浏览器展示
    用来产生图片URL：https://cn.bing.com/images/async?q=壁纸&first=150&count=35
    count <= 35

 */
```

```dart
/// baidu 百度
/// https://image.baidu.com/search/acjson?tn=resultjson_com&logid=10905178178117166935&ipn=rj&ct=201326592&is=&fp=result&fr=&word=壁纸&cg=wallpaper&queryWord=壁纸&cl=2&lm=-1&ie=utf-8&oe=utf-8&adpicid=&st=&z=&ic=&hd=&latest=&copyright=&s=&se=&tab=&width=&height=&face=&istype=&qc=&nc=1&expermode=&nojc=&isAsync=&pn=150&rn=30&gsm=96&1672755242163=
/// https://image.baidu.com/search/acjson?tn=resultjson_com&logid=10905178178117166935&ipn=rj&ct=201326592&is=&fp=result&fr=&word=壁纸&cg=wallpaper&queryWord=壁纸&cl=2&lm=-1&ie=utf-8&oe=utf-8&adpicid=&st=&z=&ic=&hd=&latest=&copyright=&s=&se=&tab=&width=&height=&face=&istype=&qc=&nc=1&expermode=&nojc=&isAsync=&pn=180&rn=30&gsm=b4&1672755242294=
```

```dart
/**
 * 经过测试，不需要headers
 */

/// 动漫基地址 https://bizhi.cheetahfun.com/dn/c2d/
/// 动漫第二页 https://bizhi.cheetahfun.com/dn/c2d/p2
///
/// 风景      https://bizhi.cheetahfun.com/dn/c1d/p2
/// 科技      https://bizhi.cheetahfun.com/dn/c7d/
/// 搜索      https://bizhi.cheetahfun.com/search.html?search=%E5%8A%A8%E6%BC%AB&page=1
///
///
/// 获取种类  document.querySelectorAll("li ul>li>a")
/// 分类(/首页)/搜索获取链接  document.querySelectorAll("section>ul>li a")
/// 获取视频里面的父节点的孩子 document.querySelector("main video").parentElement.childNodes //cou=2
///
///
/// 国内可访问

/**
 * package:html 0.15.0 0.15.1 的 bug
 * querySelectorAll("section>ul>li>div>a")  ->得到结果
 * querySelectorAll("section>ul>li a")      ->什么都没有
 */
```