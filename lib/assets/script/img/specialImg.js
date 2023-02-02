let styleCss = document.createElement("style")
styleCss.setAttribute("type","text/css")
styleCss.innerHTML = `
body{
    overflow: hidden;
}
@keyframes bg_change {
    0%{
        left: 96px;
        top: 300px;
        opacity: 0;
    }
    50%{
        right: -96px;
        bottom: -300px;
        width: 50%;
        height: 50%;
        transform: perspective(400px) rotateX(180deg) rotateY(-90deg) translateX(0px) translateY(100px) translateZ(-100px);
        opacity: 0.5;
    }
    100%{
        left: 0;
        top: 0;
        right: 0;
        width: 100%;
        height: 100%;
        transform: perspective(800px) rotateX(0deg) rotateY(13.3046deg) translateX(147.964px) translateY(41.5282px) translateZ(-112.439px);
        opacity: 1;
    }
}
.fly{
    width: 33%;
    height: 20%;
    position: absolute;
    animation:bg_change 10s infinite;
    -webkit-animation:bg_change 10s infinite;
}


@keyframes base_change {
    0%{
        opacity: 0;
        transform: translateX(0) translateY(0);
    }
    50%{
        opacity: 0.5;
        transform: translateX(50%) translateY(-50%) ;
    }
    100%{
        opacity: 1;
        transform: translateX(100%) translateY(-100%) ;
    }
}

.base{
    width: 100%;
    height: 100%;
    position: absolute;
    animation:base_change 10s infinite;
    -webkit-animation:base_change 10s infinite;
}
#back-img-box{
    position:fixed;
    left: 0;
    top: 0;
    width: 100%;
    height:100%;
    opacity: 1;
    z-index: -1;
}
`
document.head.appendChild(styleCss)

let backImgBox = document.createElement("div")
backImgBox.setAttribute("id","back-img-box")
backImgBox.innerHTML =
`
    <img src="https://tuapi.eees.cc/api.php?category=dongman&type=302" id="back-img-base" class="base"/>
    <img class="fly"/>
    <img class="fly"/>
    <img class="fly"/>
    <img class="fly"/>
    <img class="fly"/>
`

document.body.appendChild(backImgBox)

let _width = window.innerWidth;
let _height = window.innerHeight;
let imgBox = document.querySelector("#back-img-box");
let nowR = 0;
let beforeR = 0;
for(let i = 1;i < imgBox.children.length;i++){
    imgBox.children[i].style.transform = `perspective(${_width}px) rotateX(${(Math.random()*_width-_width)}deg) rotateY(${(Math.random()*_height-_height)}deg) translateX(${(Math.random()*_width-_width)}px) translateY(${(Math.random()*_height-_height)}px) translateZ(${(Math.random()*(0.5*_width + 0.5 * _height)-(0.5*_width + 0.5*_height))}px)`;
    imgBox.children[i].style.opacity = 0.5
    imgBox.children[i].src = "https://tuapi.eees.cc/api.php?category=dongman&type=302"
}
setInterval(()=>{
    nowR = parseInt(Math.random()*100);
    document.querySelector("#back-img-base").src = "https://tuapi.eees.cc/api.php?category=dongman&type=302&r=" + nowR;
    for(let i = 1;i < imgBox.children.length;i++){
        imgBox.children[i].src = "https://tuapi.eees.cc/api.php?category=dongman&type=302&r=" + beforeR
    }
    beforeR = nowR
},10000)