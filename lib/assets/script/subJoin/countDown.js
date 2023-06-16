(()=>{
    /**
     * 实现了倒计时的效果，直接导入代码即可
     *  这个功能是专门为有着时间倒计时功能设计的
     */
    const style_str = `<style>
    #count_down *{
        text-align: center;
    }
    #count_down{
      font-family: Arial, sans-serif;
      color: red;
    }
    .time_h2 {
      font-size: 24px;
      font-weight: normal;
      margin-top: 0;
      margin-bottom: 10px;
    }
    #current-time {
      font-size: 32px;
      font-weight: bold;
      color: #af8f5e;
     animation: pulse 1s ease-in-out infinite;
   }
    #time-diff {
      font-size: 2em;
      font-weight: bold;
      text-shadow: 2px 2px #F3F3F3;
      color: red;
    }
   @keyframes pulse {
     from {
       transform: scale(1);
    }
      to {
       transform: scale(1.1);
      }
    }
 </style>`
    const html_str = `
<div id="count_down" style="position: absolute;left: 0;top: 0;width: 100%;background: transparent; opacity: 0.7;">
    <h2 class="time_h2">2023年12月24日 0时0分0秒</h2>
    <h2 class="time_h2"><span id="current-time"></span></h2>
    <h2 class="time_h2"><span id="time-diff"></span></h2>
</div>
${style_str}
`
    function formatTimeDiffDayMax(timeInSeconds) {
        const dayInSeconds = 24 * 60 * 60;
        const hourInSeconds = 60 * 60;
        const minuteInSeconds = 60;

        const days = Math.floor(timeInSeconds / dayInSeconds);
        const hours = Math.floor((timeInSeconds % dayInSeconds) / hourInSeconds);
        const minutes = Math.floor((timeInSeconds % hourInSeconds) / minuteInSeconds);
        const seconds = timeInSeconds % minuteInSeconds;

        let result = '';
        if (days > 0) {
            result += `${days}天`;
        }
        if (hours > 0) {
            result += `${hours}小时`;
        }
        if (minutes > 0) {
            result += `${minutes}分`;
        }
        result += `${seconds}秒`;

        return result;
    }


    function formatTimeDiff(timeDiffInSeconds) {
        const secondsPerMinute = 60;
        const secondsPerHour = secondsPerMinute * 60;
        const secondsPerDay = secondsPerHour * 24;
        const secondsPerMonth = secondsPerDay * 30;
        const secondsPerYear = secondsPerDay * 365;
        const years = Math.floor(timeDiffInSeconds / secondsPerYear);
        timeDiffInSeconds -= years * secondsPerYear;
        const months = Math.floor(timeDiffInSeconds / secondsPerMonth);
        timeDiffInSeconds -= months * secondsPerMonth;
        const days = Math.floor(timeDiffInSeconds / secondsPerDay);
        timeDiffInSeconds -= days * secondsPerDay;
        const hours = Math.floor(timeDiffInSeconds / secondsPerHour);
        timeDiffInSeconds -= hours * secondsPerHour;
        const minutes = Math.floor(timeDiffInSeconds / secondsPerMinute);
        timeDiffInSeconds -= minutes * secondsPerMinute;
        let message = '';
        if (years > 0) {
            message += `${years}年`;
        }
        if (months > 0) {
            message += `${months}个月`;
        }
        if (days > 0) {
            message += `${days}天`;
        }
        if (hours > 0) {
            message += `${hours}小时`;
        }
        if (minutes > 0) {
            message += `${minutes}分钟`;
        }
        if (timeDiffInSeconds > 0 || message === '') {
            message += `${timeDiffInSeconds}秒`;
        }
        return message;
    }
    const standardTime = new Date('2023-12-24T00:00:00.000Z');
    const box = document.createElement("div")
    box.innerHTML = html_str
    let currentTime = new Date();
    let diffInMs = standardTime - currentTime;
    let diffInSec = Math.floor(diffInMs / 1000);
    document.body.append(box)
    setInterval(()=>{
        currentTime = new Date();
        diffInMs = standardTime - currentTime;
        diffInSec = Math.floor(diffInMs / 1000);
        document.getElementById('current-time').textContent = currentTime.toLocaleString('zh-CN', {timeZone: 'Asia/Shanghai'});
        document.getElementById('time-diff').textContent = `${formatTimeDiff(diffInSec)} // ${formatTimeDiffDayMax(diffInSec)}`;
    },1000)
})()