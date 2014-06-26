module(..., package.seeall)
function create(obj, image, width, height, frames)
	local boom = graphics.newImageSheet( image, { width = width, height = height, numFrames = frames } )
	local explosion = display.newSprite( boom, { name="boom", start=1, count = frames, time=1000, loopCount = 1 } )
	explosion.x = obj.x
	explosion.y = obj.y
	explosion:play()
end