module(..., package.seeall)
function create(image, x, y, interv)
	local enemy
	enemy = display.newImage(image) 
	enemy.x = x
	enemy.y = y
	physics.addBody(enemy, "dynamic", {density=5, bounce = 0, friction = 0})
	enemy.name = "enemy"
	enemy.id = 0
	enemy.collision = onCollision
	enemy:addEventListener("collision", enemy)
	enemy.timeLastEnemyBullet = 0
	enemy.interv = interv
	return enemy
end