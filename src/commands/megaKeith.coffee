megaKeithGif = require("../megakeith/megaKeith.gif");
megaKeithSound = require("../megakeith/megaKeith.mp3");
smokeParticles = [
  require("../megakeith/smoke1.png"),
  require("../megakeith/smoke2.png"),
  require("../megakeith/smoke3.png"),
  require("../megakeith/smoke4.png"),
  require("../megakeith/smoke5.png"),
]

export default (command, args) ->
  if command == "\\megaKeith"
    keithWidth = window.innerWidth * 0.7
    megaKeith = document.createElement "img"
    megaKeith.src = megaKeithGif
    megaKeith.style = "position: absolute; bottom: 0px; z-index: 10000; left: #{(window.innerWidth - keithWidth) * 0.5}px; width: #{keithWidth}px;"
    document.body.appendChild(megaKeith)
    audio = document.createElement "audio"
    audio.src = megaKeithSound
    audio.volume = "0.4"
    audio.autoplay = "autoplay"
    document.body.appendChild(audio)
    setInterval(() ->
      smokeId = ""
      for i in [0..20]
        smokeId += Math.floor(Math.random() * 10).toString();
      smokeKeyFrames = """
  @keyframes Smoke#{smokeId} {
  0% { opacity: 0; bottom: -200px; transform: rotate(#{Math.random() * 360}deg); }
  80% { opacity: 0.8; }
  100% { opacity: 0; transform: rotate(#{Math.random() * 360}deg); bottom: 50px; }
  }"""
      smokeKeyframe = document.createElement "style"
      smokeKeyframe.type = "text/css"
      smokeKeyframe.appendChild(document.createTextNode(smokeKeyFrames))
      document.head.appendChild(smokeKeyframe);
      smoke = document.createElement "img"
      smoke.src = smokeParticles[Math.floor(Math.random() * 5)]
      smoke.style = "position: absolute; left: #{Math.random() * window.innerWidth}px; animation: Smoke#{smokeId} 3s; opacity: 0; z-index: 50000;"
      document.body.appendChild(smoke)
    , 100)
    setTimeout(() ->
      location.reload(true)
    , 15000)
