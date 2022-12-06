import anime from "animejs";

let gacha = document.getElementById('one-gacha-machine');
let clickCnt = 0;

gacha.addEventListener('click',function(){
    if (clickCnt == 0) {
        let animation = anime({
            targets: gacha,
            translateX: 10,
            duration: 1000,
            loop: true,
            autoplay: false,
        });
        animation.play();
        document.getElementById("gacha-form-text").style.display = "block";
        const BASE_URL = gon.base_url;
        const schedule = document.getElementById("schedule").innerText;
        document.getElementById("gacha-form-text").style.display = "block";
        axios.get(BASE_URL+"select_by_schedule?schedule="+schedule, {timeout: 70000})
        .then(() => {
            animation.pause();
            const target = document.getElementById("to-result");
            target.innerText = "ガチャから取り出す";
            target.classList.remove("disabled");
        });
        clickCnt += 1;
    }
});


function TextTypingAnime() {
    $('.text-typing').each(function () {
        let elemPos = $(this).offset().top - 50;
        let scroll = $(window).scrollTop();
        let windowHeight = $(window).height();
        let thisChild = "";
        if (scroll >= elemPos - windowHeight) {
            thisChild = $(this).children(); //spanタグを取得
            //spanタグの要素の１つ１つ処理を追加
            thisChild.each(function (i) {
                let time = 100;
                //時差で表示する為にdelayを指定しその時間後にfadeInで表示させる
                $(this).delay(time * i);
                $(this).delay(time * i).fadeIn(time);
            });
        } else {
            thisChild = $(this).children();
            thisChild.each(function () {
            $(this).stop(); //delay処理を止める
            $(this).css("display", "none"); //spanタグ非表示
            });
        }   
    });
}

// 画面をスクロールをしたら動かしたい場合の記述
$(window).scroll(function () {
    TextTypingAnime();/* アニメーション用の関数を呼ぶ*/
});// ここまで画面をスクロールをしたら動かしたい場合の記述

// 画面が読み込まれたらすぐに動かしたい場合の記述
$(window).on('load', function () {
    //spanタグを追加する
    let element = $(".text-typing");
    element.each(function () {
        let text = $(this).html();
        let textbox = "";
        text.split('').forEach(function (t) {
            if (t !== " ") {
            textbox += '<span>' + t + '</span>';
            } else {
            textbox += t;
            }
        });
        $(this).html(textbox);
    });
    TextTypingAnime();/* アニメーション用の関数を呼ぶ*/
});