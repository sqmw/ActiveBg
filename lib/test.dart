import 'package:active_bg/utils/DataUtil.dart';
import 'package:dio/dio.dart';

void main()async{
  List list = await DataUtil.getImgAbsUrls(ques: "壁纸", start: 150);
  print(list);
}

/// //div[@id='mmComponent_images_1']//li//a/@m
/// m 里面的murl 是真实地址
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