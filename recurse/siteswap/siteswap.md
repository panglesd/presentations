---
dimension: 16:9
js: simulation.js
css: style.css
---

# Siteswap

{style=text-align:center}
<canvas id="juggleCanvas" width="800" height="900"></canvas>

<div id="patternDisplay"></div>

{focus="~margin:100 juggleCanvas patternDisplay"}

{exec}
```slip-script
sim = api.init_simulation(document.getElementById('juggleCanvas'));
const displayDiv = document.getElementById('patternDisplay');
let isTimeOn = false;
let isHandsOn = false;
let isSoundOn = false;
let soundMode = 'throw'; // 'throw' or 'catch'
api.add_callback(sim, displayDiv);
api.set_siteswap(sim, [3]);
api.set_gravity(sim, 1400);
api.run(sim);
slip.onUndo(() => {api.pause(sim)});

set_siteswap = (slip, sim, s) => {
  let old_siteswap = sim.siteswap;
  slip.onUndo(() => { displayDiv.innerHTML = ''; api.set_siteswap(sim, old_siteswap) });
  displayDiv.innerHTML = '';
  api.set_siteswap(sim, s);
}
set_sound = (slip, sim, s) => {
  let old_sound = sim.audioEnabled;
  slip.onUndo(() => { api.set_sound_enabled(sim, old_sound); });
  api.set_sound_enabled(sim, s);
}
set_speed = (slip, sim, s) => {
  let old_speed = sim.speedScale;
  slip.onUndo(() => { api.set_speed(sim, old_speed); });
  api.set_speed(sim, s);
}
set_gravity = (slip, sim, s) => {
  let old_gravity = sim.gravity;
  slip.onUndo(() => { api.set_gravity(sim, old_gravity); });
  api.set_gravity(sim, s);
}
set_show_time_on_balls = (slip, sim, s) => {
  let old_time = sim.showTime;
  slip.onUndo(() => { api.set_show_time_on_balls(sim, old_time); });
  api.set_show_time_on_balls(sim, s);
}
```

{exec}
```slip-script
set_siteswap(slip, sim, [4])
```

{exec}
```slip-script
set_siteswap(slip, sim, [5])
```

{exec}
```slip-script
set_siteswap(slip, sim, [3,3,3,3,3,3])
```

{exec}
```slip-script
set_speed(slip, sim, 0.4)
set_sound(slip, sim, true)
set_show_time_on_balls(slip, sim, true)
```

{exec}
```slip-script
set_siteswap(slip, sim, [4,4,1])
```

{exec}
```slip-script
slip.onUndo(() => { isHandsOn = false })
isHandsOn = true
```

{exec}
```slip-script
slip.onUndo(() => { isHandsOn = false })
isHandsOn = true
set_show_time_on_balls(slip, sim, false)
set_speed(slip, sim, 1.75)
```

{exec}
```slip-script
set_siteswap(slip, sim, [5,3,1])
set_speed(slip, sim, 1)
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{exec}
```slip-script
set_siteswap(slip, sim, [2])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{exec}
```slip-script
set_siteswap(slip, sim, [4,2,3])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{exec}
```slip-script
set_siteswap(slip, sim, [5,2,2])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{exec}
```slip-script
set_siteswap(slip, sim, [5,5,5, 0, 0])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{exec}
```slip-script
set_siteswap(slip, sim, [6, 0])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```
