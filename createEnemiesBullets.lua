module(..., package.seeall)
function create(enemy, image)
	local Ebullet = display.newImage(image)
	Ebullet.x = enemy.x - enemy.contentWidth * .5
	Ebullet.y = enemy.y

	-- Kinematic, so it doesn't react to gravity.
	physics.addBody(Ebullet, "dynamic", {density=1000, bounce = 0, friction = 0})
	Ebullet.name = "ebullet"
	-- Listen to collisions, so we may know when it hits an enemy.
	Ebullet.collision = onCollision
	Ebullet:addEventListener("collision", Ebullet)
	transition.to(Ebullet, {time = 1000, x = enemy.x - 300,
	onComplete = function(self) if self.parent then self.parent:remove(self); self = nil; end end
	})
	return Ebullet
end