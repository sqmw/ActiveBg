const particle_canvas = document.createElement("canvas");
particle_canvas.setAttribute("id","particle_canvas")
document.querySelector("body").appendChild(particle_canvas)
 
const ctx = particle_canvas.getContext('2d');
particle_canvas.width = window.innerWidth;
particle_canvas.height = window.innerHeight;
let particles = [];
 
window.addEventListener('resize', function(e) {
	particle_canvas.width = window.innerWidth;
	particle_canvas.height = window.innerHeight;
});
 
let hueCol = 0;
 
const mouse = {
	x: undefined,
	y: undefined,
}
 
particle_canvas.addEventListener('click', function(e) {
	mouse.x = e.x;
	mouse.y = e.y;
	for (let i = 0; i < 5; i++) {
		particles.push(new Particle);
	}
})

// particle_canvas.addEventListener('mousemove', function(e) {
// 	mouse.x = e.x;
// 	mouse.y = e.y;
// 	for (let i = 0; i < 5; i++) {
// 		particles.push(new Particle);
// 	}
// })
 
class Particle {
	constructor() {
		this.x = mouse.x;
		this.y = mouse.y;
		this.speedX = Math.random() * 3 - 1.5;
		this.speedY = Math.random() * 3 - 1.5;
		this.color = 'hsl(' + hueCol + ', 100%, 50%)';
		this.size = Math.random() * 5 + 1;
	}
	update() {
		this.x += this.speedX;
		this.y += this.speedY;
		this.size -= 0.1;
	}
	draw() {
		ctx.fillStyle = this.color;
		ctx.beginPath();
		ctx.arc(this.x, this.y, 5, 0, Math.PI * 2);
		ctx.fill();
	}
}
 
function handleParticles() {
	for (var i = 0; i < particles.length; i++) {
		particles[i].update();
		particles[i].draw();
		for (var j = i + 1; j < particles.length; j++) {
			const dx = particles[j].x - particles[i].x;
			const dy = particles[j].y - particles[i].y;
			const distance = dx * dx + dy * dy;
			if (distance < 10000) {
				ctx.beginPath();
				ctx.strokeStyle = particles[i].color;
				ctx.lineWidth = 0.3;
				ctx.moveTo(particles[i].x, particles[i].y);
				ctx.lineTo(particles[j].x, particles[j].y);
				ctx.stroke();
			}
		}
		if (particles.size < 0.3) {
			particles.splice(i, 1);
			i--;
		}
	}
}
 
function animate() {
	ctx.clearRect(0, 0, particle_canvas.width, particle_canvas.height);
	handleParticles();
	hueCol += 2;
	requestAnimationFrame(animate);
}
 
animate();