class JugglingSimulation {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.width = canvas.width;
        this.height = canvas.height;

        this.gravity = 2000;
        this.beatTime = 0.45; 
        this.dwellRatio = 0.5; 
        this.speedScale = 1.0;
        this.ballRadius = 26; 
        this.showTime = false;
        
        // Audio State
        this.audioEnabled = false;
        this.audioMode = 'throw'; // 'throw' or 'catch'
        this.audioCtx = null;
        
        this.siteswap = [];   
        this.props = []; 
        this.activeBalls = []; 
        this.schedule = {}; 
        this.unusedProps = [];
        
        this.beatIndex = 0; 
        this.timeAccumulator = 0; 
        this.lastFrameTime = 0;
        this.isRunning = false;
        
        this.onBeatChange = null; 
        this.palette = ['#e74c3c', '#2ecc71', '#3498db', '#9b59b6', '#f1c40f', '#e67e22', '#1abc9c'];
        
        const yPos = this.height * 0.85; 
        this.hands = {
            left:  { catch: {x: this.width * 0.31, y: yPos}, throw: {x: this.width * 0.46, y: yPos} },
            right: { catch: {x: this.width * 0.69, y: yPos}, throw: {x: this.width * 0.54, y: yPos} }
        };
    }

    // --- AUDIO METHODS ---
    initAudio() {
        if (!this.audioCtx) {
            this.audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        }
        if (this.audioCtx.state === 'suspended') {
            this.audioCtx.resume();
        }
    }

    setSoundEnabled(bool) {
        this.audioEnabled = bool;
        if(bool) this.initAudio();
    }

    setSoundMode(mode) {
        this.audioMode = mode;
    }

    playTick(val) {
        if (!this.audioEnabled || !this.audioCtx || val === 0) return;

        // Simple pitch mapping: Base + (Val * Step)
        // e.g. 1->400, 3->600, 5->800
        const freq = 300 + (val * 100);

        const osc = this.audioCtx.createOscillator();
        const gain = this.audioCtx.createGain();

        osc.type = 'sine';
        osc.frequency.value = freq;

        osc.connect(gain);
        gain.connect(this.audioCtx.destination);

        const now = this.audioCtx.currentTime;
        
        // Envelope for a "tick" sound
        gain.gain.setValueAtTime(0, now);
        gain.gain.linearRampToValueAtTime(0.15, now + 0.01);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.1);

        osc.start(now);
        osc.stop(now + 0.15);
    }
    // ---------------------

    setShowTime(bool) { this.showTime = bool; }
    setGravity(g) { this.gravity = g; }
    setSpeed(s) { this.speedScale = s; }
    setBeatCallback(cb) { this.onBeatChange = cb; }

    setPattern(pattern) {
        this.siteswap = pattern;
        this.reset();
        
        const avg = pattern.reduce((a, b) => a + b, 0) / pattern.length;
        const numBalls = Math.floor(avg);
        
        this.props = [];
        for(let i=0; i<numBalls; i++) {
            this.props.push({
                id: i,
                color: this.palette[i % this.palette.length]
            });
        }
        this.unusedProps = [...this.props];
        this.checkHighlight(true);
    }

    reset() {
        this.activeBalls = [];
        this.schedule = {};
        this.beatIndex = 0;
        this.timeAccumulator = this.beatTime;
    }

    start() {
        if (this.isRunning) return;
        this.initAudio(); // Try to init if starting
        this.isRunning = true;
        this.lastFrameTime = performance.now();
        this.loop();
    }

    stop() {
        this.isRunning = false;
        cancelAnimationFrame(this.animId);
    }

    triggerUIUpdate() {
        this.checkHighlight(true);
    }

    update(dt) {
        const simDt = dt * this.speedScale;
        this.timeAccumulator += simDt;
        
        // --- CATCH SOUND CHECK (Done per frame) ---
        // We check balls that are currently flying. 
        // If they just passed the flight duration, we play the catch sound.
        if (this.audioEnabled && this.audioMode === 'catch') {
            const globalBeatTime = this.beatIndex + (this.timeAccumulator / this.beatTime) - 1;
            
            this.activeBalls.forEach(ball => {
                if (ball.playedCatchSound) return;

                const durationBeats = ball.endBeat - ball.startBeat;
                const flightDuration = Math.max(0.1, durationBeats - this.dwellRatio);
                const tBeats = globalBeatTime - ball.startBeat;

                // If we passed the flight duration, play sound
                if (tBeats >= flightDuration) {
                    // To avoid playing sounds for old balls when switching modes, 
                    // ensure we are reasonably close to the event (within 1 beat)
                    if (tBeats < durationBeats + 1) {
                        // Pitch is based on the throw value that resulted in this catch
                        // We can derive the value from durationBeats
                        this.playTick(durationBeats);
                    }
                    ball.playedCatchSound = true;
                }
            });
        }

        while (this.timeAccumulator >= this.beatTime) {
            this.processBeat();
            this.timeAccumulator -= this.beatTime;
        }

        this.checkHighlight(false);
    }

    checkHighlight(force) {
        if(!this.onBeatChange || this.siteswap.length === 0) return;

        let activeIdx = this.beatIndex > 0 ? this.beatIndex - 1 : 0;
        const dwellThreshold = this.beatTime * (1 - this.dwellRatio);
        let previewIdx = null;

        if (this.timeAccumulator >= dwellThreshold) {
            previewIdx = this.beatIndex; 
        }

        if (force || activeIdx !== this._lastActive || previewIdx !== this._lastPreview) {
            this._lastActive = activeIdx;
            this._lastPreview = previewIdx;
            this.onBeatChange(activeIdx, previewIdx, this.siteswap);
        }
    }

    processBeat() {
        const currentBeat = this.beatIndex;
        this.activeBalls = this.activeBalls.filter(b => b.endBeat > currentBeat);

        if (this.siteswap.length === 0) return;

        const patternIdx = currentBeat % this.siteswap.length;
        const patternVal = this.siteswap[patternIdx];
        
        // --- THROW SOUND CHECK ---
        if (this.audioEnabled && this.audioMode === 'throw' && patternVal !== 0) {
            this.playTick(patternVal);
        }
        
        let propId = this.schedule[currentBeat];
        if (propId === undefined && patternVal !== 0 && this.unusedProps.length > 0) {
            propId = this.unusedProps.shift().id;
        }

        if (propId !== undefined && patternVal !== 0) {
            const landBeat = currentBeat + patternVal;
            this.schedule[landBeat] = propId;

            const isRightHand = (currentBeat % 2) === 0;
            const throwHand = isRightHand ? this.hands.right : this.hands.left;
            const landsInRight = (patternVal % 2 !== 0) ? !isRightHand : isRightHand;
            const catchHand = landsInRight ? this.hands.right : this.hands.left;

            this.activeBalls.push({
                propId: propId,
                startBeat: currentBeat,
                endBeat: landBeat, 
                throwPos: throwHand.throw,
                catchPos: catchHand.catch,
                nextThrowPos: catchHand.throw,
                playedCatchSound: false // Flag for catch audio
            });
        }

        this.beatIndex++;
        delete this.schedule[currentBeat]; 
    }

    getPropColor(id) {
        return (this.props.find(x => x.id === id) || {color:'#fff'}).color;
    }

    draw() {
        this.ctx.clearRect(0, 0, this.width, this.height);
        
        const globalBeatTime = this.beatIndex + (this.timeAccumulator / this.beatTime) - 1; 

        // Hands
        this.ctx.fillStyle = '#555';
        [this.hands.left, this.hands.right].forEach(h => {
            this.ctx.beginPath(); this.ctx.ellipse(h.catch.x, h.catch.y, 20, 5, 0, 0, Math.PI*2); this.ctx.fill();
            this.ctx.beginPath(); this.ctx.ellipse(h.throw.x, h.throw.y, 20, 5, 0, 0, Math.PI*2); this.ctx.fill();
        });

        this.activeBalls.forEach(ball => {
            const durationBeats = ball.endBeat - ball.startBeat;
            const tBeats = globalBeatTime - ball.startBeat; 
            
            if (tBeats < 0) return; 
            
            const flightDuration = Math.max(0.1, durationBeats - this.dwellRatio);
            let pos = {x:0, y:0};
            
            if (tBeats <= flightDuration) {
                // Flight
                const t = tBeats / flightDuration;
                pos.x = ball.throwPos.x + (ball.catchPos.x - ball.throwPos.x) * t;
                const T_flight_sec = flightDuration * this.beatTime;
                const t_sec = t * T_flight_sec;
                const vy = 0.5 * this.gravity * T_flight_sec;
                const dy = (vy * t_sec) - (0.5 * this.gravity * t_sec * t_sec);
                pos.y = ball.throwPos.y - dy;
            } else {
                // Scoop
                const dwellTime = tBeats - flightDuration;
                const dwellTotal = durationBeats - flightDuration; 
                let t = dwellTime / dwellTotal;
                if(t > 1) t = 1; 
                const p0 = ball.catchPos;
                const p2 = ball.nextThrowPos;
                const cx = (p0.x + p2.x) / 2;
                const cy = p0.y + 120; 
                pos.x = (1-t)*(1-t)*p0.x + 2*(1-t)*t*cx + t*t*p2.x;
                pos.y = (1-t)*(1-t)*p0.y + 2*(1-t)*t*cy + t*t*p2.y;
            }

            this.ctx.fillStyle = this.getPropColor(ball.propId);
            this.ctx.beginPath();
            this.ctx.arc(pos.x, pos.y, this.ballRadius, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.strokeStyle = '#fff';
            this.ctx.lineWidth = 3;
            this.ctx.stroke();

            if (this.showTime) {
                const currentBeatInterval = Math.floor(globalBeatTime);
                const displayNum = ball.endBeat - currentBeatInterval;
                if (displayNum > 0) {
                    this.ctx.strokeStyle = '#000';
                    this.ctx.lineWidth = 4;
                    this.ctx.font = 'bold 28px Arial';
                    this.ctx.textAlign = 'center';
                    this.ctx.textBaseline = 'middle';
                    this.ctx.strokeText(displayNum, pos.x, pos.y + 2);
                    this.ctx.fillStyle = '#fff';
                    this.ctx.fillText(displayNum, pos.x, pos.y + 2);
                }
            }
        });
    }

    loop() {
        if (!this.isRunning) return;
        const now = performance.now();
        const dt = (now - this.lastFrameTime) / 1000;
        this.lastFrameTime = now;
        this.update(dt);
        this.draw();
        this.animId = requestAnimationFrame(() => this.loop());
    }
}

// ---------------------------------------------------------
// API & UI
// ---------------------------------------------------------
let isTimeOn = false;
let isHandsOn = false; 
let isSoundOn = false;
let soundMode = 'throw'; // 'throw' or 'catch'


let api = {
    init_simulation: (c) => new JugglingSimulation(c),
    set_siteswap: (s, p) => s.setPattern(p),
    run: (s) => s.start(),
    pause: (s) => s.stop(),
    set_speed: (s, v) => s.setSpeed(v),
    set_gravity: (s, v) => s.setGravity(v),
    set_show_time_on_balls: (s, b) => s.setShowTime(b),
    set_beat_callback: (s, cb) => s.setBeatCallback(cb),
    trigger_ui_update: (s) => s.triggerUIUpdate(),
    
    // Audio APIs
    set_sound_enabled: (s, b) => s.setSoundEnabled(b),
    set_sound_mode: (s, m) => s.setSoundMode(m),

    add_callback: (s, displayDiv) => {
        s.setBeatCallback((activeBeatIdx, previewBeatIdx, pattern) => {
            let displayPattern = pattern;
            if (isHandsOn && pattern.length % 2 !== 0) {
                displayPattern = [...pattern, ...pattern];
            }
            
            if (displayDiv.childElementCount !== displayPattern.length) {
                displayDiv.innerHTML = '';
                displayPattern.forEach((val, i) => {
                    const span = document.createElement('span');
                    span.className = 'throw-val';
                    if (isHandsOn) {
                        if (i % 2 === 0) span.classList.add('hand-right');
                        else span.classList.add('hand-left');
                    }
                    span.innerText = val;
                    displayDiv.appendChild(span);
                });
            }
            
            const activeWrapped = activeBeatIdx % displayPattern.length;
            let previewWrapped = -1;
            if (previewBeatIdx !== null) {
                previewWrapped = previewBeatIdx % displayPattern.length;
            }

            Array.from(displayDiv.children).forEach((child, i) => {
                child.className = 'throw-val'; 
                if (isHandsOn) {
                    if (i % 2 === 0) child.classList.add('hand-right');
                    else child.classList.add('hand-left');
                }

                if(i === activeWrapped) {
                    child.classList.add('active');
                }
                else if (i === previewWrapped) {
                    child.classList.add('preview');
                }
            });
        });
    }

};

// const sim = api.init_simulation(document.getElementById('juggleCanvas'));
// const displayDiv = document.getElementById('patternDisplay');

// let isTimeOn = false;
// let isHandsOn = false; 
// let isSoundOn = false;
// let soundMode = 'throw'; // 'throw' or 'catch'

// api.set_beat_callback(sim, (activeBeatIdx, previewBeatIdx, pattern) => {

//     let displayPattern = pattern;
//     if (isHandsOn && pattern.length % 2 !== 0) {
//         displayPattern = [...pattern, ...pattern];
//     }

//     if (displayDiv.childElementCount !== displayPattern.length) {
//         displayDiv.innerHTML = '';
//         displayPattern.forEach((val, i) => {
//             const span = document.createElement('span');
//             span.className = 'throw-val';
//             if (isHandsOn) {
//                 if (i % 2 === 0) span.classList.add('hand-right');
//                 else span.classList.add('hand-left');
//             }
//             span.innerText = val;
//             displayDiv.appendChild(span);
//         });
//     }

//     const activeWrapped = activeBeatIdx % displayPattern.length;
//     let previewWrapped = -1;
//     if (previewBeatIdx !== null) {
//         previewWrapped = previewBeatIdx % displayPattern.length;
//     }

//     Array.from(displayDiv.children).forEach((child, i) => {
//         child.className = 'throw-val'; 
//         if (isHandsOn) {
//             if (i % 2 === 0) child.classList.add('hand-right');
//             else child.classList.add('hand-left');
//         }

//         if(i === activeWrapped) {
//             child.classList.add('active');
//         }
//         else if (i === previewWrapped) {
//             child.classList.add('preview');
//         }
//     });
// });

// api.set_siteswap(sim, [5,3,1]);
// api.run(sim);

function updatePattern() {
    const val = document.getElementById('patternInput').value;
    try {
        const arr = val.split(',').map(n => parseInt(n.trim(), 10));
        if (arr.some(isNaN)) throw new Error("NaN");
        displayDiv.innerHTML = ''; 
        api.set_siteswap(sim, arr);
    } catch(e) { alert("Invalid Pattern"); }
}

function toggleTime() {
    isTimeOn = !isTimeOn;
    api.set_show_time_on_balls(sim, isTimeOn);
    const btn = document.getElementById('btnTime');
    btn.innerText = `Show Time: ${isTimeOn ? 'ON' : 'OFF'}`;
    btn.className = isTimeOn ? 'toggle-on' : '';
}

function toggleHands() {
    isHandsOn = !isHandsOn;
    displayDiv.innerHTML = '';
    api.trigger_ui_update(sim);
    const btn = document.getElementById('btnHands');
    btn.innerText = `Split Hands: ${isHandsOn ? 'ON' : 'OFF'}`;
    btn.className = isHandsOn ? 'toggle-on' : '';
}

function toggleSound() {
    isSoundOn = !isSoundOn;
    api.set_sound_enabled(sim, isSoundOn);
    const btn = document.getElementById('btnSound');
    btn.innerText = `Sound: ${isSoundOn ? 'ON' : 'OFF'}`;
    btn.className = isSoundOn ? 'toggle-on' : '';
}

function toggleSoundMode() {
    soundMode = (soundMode === 'throw') ? 'catch' : 'throw';
    api.set_sound_mode(sim, soundMode);
    const btn = document.getElementById('btnSoundMode');
    btn.innerText = `Mode: ${soundMode.toUpperCase()}`;
    // Change color based on mode
    btn.className = (soundMode === 'catch') ? 'toggle-mode' : ''; 
}
