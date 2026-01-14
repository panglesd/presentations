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
slip.onUndo(() => { isHandsOn = true })
isHandsOn = false
set_show_time_on_balls(slip, sim, false)
set_speed(slip, sim, 1.65)
```

{exec}
```slip-script
set_speed(slip, sim, 1.70)
set_siteswap(slip, sim, [5,3,1])
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
set_gravity(slip, sim, 1000);
set_siteswap(slip, sim, [6])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{exec}
```slip-script
set_gravity(slip, sim, 1000);
set_siteswap(slip, sim, [6, 0])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{exec}
```slip-script
set_gravity(slip, sim, 1000);
set_siteswap(slip, sim, [1,2,3,4,5])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{exec}
```slip-script
set_gravity(slip, sim, 1000);
set_siteswap(slip, sim, [1,2,3,4,5,6,7])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{exec}
```slip-script
set_siteswap(slip, sim, [0])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{exec}
```slip-script
set_siteswap(slip, sim, [5,3,1])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{exec}
```slip-script
set_gravity(slip, sim, 700);
set_siteswap(slip, sim, [7,5,3,1])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{exec}
```slip-script
set_gravity(slip, sim, 400);
set_siteswap(slip, sim, [9,7,5,3,1])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{exec}
```slip-script
set_gravity(slip, sim, 400);
set_siteswap(slip, sim, [8,6,2,7,7])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{exec}
```slip-script
set_gravity(slip, sim, 250);
set_siteswap(slip, sim, [11,8,10,7,11,9,7,0,0])
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "0")
```

{exec}
```slip-script
slip.setStyle(document.getElementById('patternDisplay'), "opacity", "1")
```

{pause focus=ig}
{exec}
```slip-script
set_sound(slip, sim, false)
```

{include #ig style=display:inline-block src=instagram.md}

{unfocus up}
# And mathematics!

{.theorem}
Some siteswap are invalids

![](si1.draw){draw}

{.theorem pause style=margin-top:220px}
The average number of a valid siteswap is the number of objects

![](s2.draw){draw}

{.theorem #gene pause style=margin-top:300px}
We can generate all siteswaps with a number of objects and maximum height

{.theorem pause up=gene}
> We can generate siteswap by modifying existing ones:
>
> - By adding $+1$ to every numbers.
> - By swaping two landing times

![](s3.draw){draw}

{.theorem pause}
> There are some classes of siteswaps
>
> $(2n+1)(2n-1)\cdots97531$


{pause up}
# And more fun!

- Siteswaps but [in](https://passist.org/siteswap/867?jugglers=2) [3D](https://passist.org/siteswap/IGH?jugglers=5)

- More siteswap [in real life](https://www.youtube.com/watch?v=51shXjTnA-8)

- Juggling is [more](https://www.youtube.com/watch?v=ATqYARL2Im8) than [just numbers](https://www.youtube.com/watch?v=l0-MXdFfqMc)

