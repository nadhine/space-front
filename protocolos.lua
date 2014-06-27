module(..., package.seeall)

function destroyEnemy(playerId, enemyX, enemyY)
	proto = {};
	proto["playerId"] = playerId;
	proto["enemyX"] = enemyX;
	proto["enemyY"] = enemyY;
	proto["protocolo"] = "destroyEnemy";
	return proto;
end

function positionPlayer(playerId, playerX, playerY)
	local proto;
	proto["playerId"] = playerId;
	proto["playerX"] = playerX;
	proto["playerY"] = playerY;
	proto["protocolo"] = "positionPlayer";
	return proto;
end
 
function positionPlayerBullet(playerId,bulletX,bulletY)
 	local proto;
	proto["playerId"] = playerId;
	proto["bulletX"] = bulletX;
	proto["bulletY"] = bulletY;
	proto["protocolo"] = "positionPlayerBullet";
	return proto;
 end