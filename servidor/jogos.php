<?php
//require_once('conexao.php');
require_once('Pubnub.php');

// publishkey, subscribekey, secretkey

$pubnub= new Pubnub('pub-c-1de57238-7431-46a8-a031-b27aa61227a0', 'sub-c-8fb2d29c-fd7f-11e3-8fd9-02ee2ddab7fe', 'sec-c-MmZiNjI2MjUtZmRlNy00YTNlLWE0MDMtYmEzODc4N2YyNDZk', false, false );
$here = $pubnub->here_now(array( 'channel' => 'AulaPubnub' ));
$occupancy = $here['occupancy'];
$user_ids = $here['uuids'];


function retornar($texto){
	$array = array('channel' => 'AulaPubnub','message' => $texto);
	global $pubnub;
	$info = $pubnub->publish($array);
	print_r($info);
}


function validar($texto){
	$array = explode(";",$texto);
	switch($array[1]){
		case 'insertRoom':
			//resposta: inserido
			$resposta = insertRoom();
			retornar($array[0].";".$array[1].";".$resposta);
			break;
			
		case 'insertPlayerRoom':
			//resposta: inserido ou error password ou room full
			//insertPlayerRoom($room,$player,$password = "0")
			if(count($array) == 5){
				$resposta = insertPlayerRoom($array[2],$array[3],$array[4]);
			}else{
				$resposta = insertPlayerRoom($array[2],$array[3]);
			}
			retornar($array[0].";".$array[1].";".$resposta);
			break;
		
		case 'deletePlayerRoom':
			//deletePlayerRoom($room,$player)
			// resposta: player not found ou detelet
			$resposta = deletePlayerRoom($array[2],$array[3]);
			retornar($array[0].";".$array[1].";".$resposta);
			break;
			
		case 'listRoom':
			//resposta: room-player1-player2-player3-se existes senha ou nao;
			$resposta = listRoom();
			retornar($array[0].";".$array[1].";".$resposta);
			break;
			
		case 'insertPlayer':
			//resposta: inseridou ou login ja existe
			//insertPlayer($login,$password)
			$resposta = insertPlayer($array[2],$array[3]);
			retornar($array[0].";".$array[1].";".$resposta);
			break;
			
		case 'consultPlayer':
			//resposta: true para player cadastrado e false para player nao cadastrado
			//consultPlayer($login,$password)
			$resposta = consultPlayer($array[2],$array[3]);
			retornar($array[0].";".$array[1].";".$resposta);
			break;
			
		case 'consultScore':
			//resposta: score
			//consultScore($login)
			$resposta = consultScore($array[2]);
			retornar($array[0].";".$array[1].";".$resposta);
			break;
			
		case 'updatePlayer':
			//resposta: true para score atualizado e false score nao atualizado - obs: se o score nao foi atualizado é pq ele nao é maior dq o score existente
			//updatePlayer($login,$score)
			$resposta = updatePlayer($array[2],$array[3]);
			retornar($array[0].";".$array[1].";".$resposta);
			break;
			
		case 'consultTopScore':
			//resposta: login-score dos 5 maiores pontuadores
			$resposta = consultTopScore();
			retornar($array[0].";".$array[1].";".$resposta);
			break;
	}


}

$teste = $pubnub->subscribe(array(
'channel' => 'AulaPubnub', // REQUIRED Channel to Listen
'callback' => create_function( // REQUIRED PHP 5.2.0 Method
'$message',
'validar($message["message"]["text"]); return true;'
)
));




function insertRoom(){
	$con = mysql_connect('127.0.0.1', 'roominst', 'roominst');
	$db = mysql_select_db('space_multiplayer');
	$sql = "INSERT INTO room (player1,player2,player3,password) VALUES ('0','0','0','0')";
	$exe = mysql_query($sql);
	mysql_close($con);
	return 'inserido';
}


// Feito
function insertPlayerRoom($room,$player,$password = "0"){
	$result = consultRoom($room);
	
	if($result[1] == "0"){
		$index = "player1";
	}elseif($result[2] == "0"){
		$index = "player2";
	}elseif($result[3] == "0"){
		$index = "player3";
	}else{
		return "room full";
	}
	
	if($result[1] == "0" and $result[2] == "0" and $result[3] == "0"){
		$sql = 	"UPDATE room SET $index='$player' WHERE room=$result[0]";
	}else{
		if($password==$result[4]){
			$sql = "UPDATE room SET $index='$player' WHERE room=$result[0]";
		}else{
			return "error password";
		}
	}
	
	$con = mysql_connect('127.0.0.1', 'roomupdt', 'roomupdt');
	$db = mysql_select_db('space_multiplayer');
	$exe = mysql_query($sql);
	mysql_close($con);
	return 'inserido';
}

//feito
function deletePlayerRoom($room,$player){
	$result = consultRoom($room);
	
	if($result[1] == $player){
		$index = "player1";
	}elseif($result[2] == $player){
		$index = "player2";
	}elseif($result[3] == $player){
		$index = "player3";
	}else{
		return "player not found";
	}
	
	
	$con = mysql_connect('127.0.0.1', 'roomupdt', 'roomupdt');
	$db = mysql_select_db('space_multiplayer');
	$sql = "UPDATE room SET $index='0' WHERE room=$result[0]";
	$exe = mysql_query($sql);
	mysql_close($con);
	return 'detelet';
	
}

function listRoom(){
	$con = mysql_connect('127.0.0.1', 'roomcons', 'roomcons');
	$db = mysql_select_db('space_multiplayer');
	$sql = "SELECT * FROM room";
	$exe = mysql_query($sql);
	$result="";
	while($array = mysql_fetch_array($exe)){
		
		$room = $array[0];
		$player1 = $array[1];
		$player2 = $array[2];
		$player3 = $array[3];
		if($array[4] <> "0"){
			$password = "1";//existe senha
		}else{
			$password = "0";//nao existe senha
		}
		$result .= $room."-".$player1."-".$player2."-".$player3."-".$password.";";
	}
	mysql_close($con);
	return $result;
}


function consultRoom($room){
	$con = mysql_connect('127.0.0.1', 'roomcons', 'roomcons');
	$db = mysql_select_db('space_multiplayer');
	$sql = "SELECT * FROM room WHERE room=$room";
	$exe = mysql_query($sql);
	$array = mysql_fetch_array($exe);
	mysql_close($con);
	return $array;
}


function insertPlayer($login,$password){
	$result = consultLogin($login);
	if($result[0] == null){
		$con = mysql_connect('127.0.0.1', 'playerinst', 'playerinst');
		$db = mysql_select_db('space_multiplayer');
		$sql = "INSERT INTO player (login,password) VALUES ('$login','$password')";
		$exe = mysql_query($sql);
		mysql_close($con);
		return "inserido";
	}else{
		return "login ja existe";
	}
}

function consultPlayer($login,$password){
	$con = mysql_connect('127.0.0.1', 'playercons', 'playercons');
	$db = mysql_select_db('space_multiplayer');
	$sql = "SELECT * FROM player WHERE login='$login' and password='$password'";
	$exe = mysql_query($sql);
	if(mysql_num_rows($exe) == 1){
		$result = "true";
	}else{
		$result = "false";
	}
	mysql_close($con);
	return $result;
}

function consultLogin($login){
	$con = mysql_connect('127.0.0.1', 'playercons', 'playercons');
	$db = mysql_select_db('space_multiplayer');
	$sql = "SELECT * FROM player WHERE login='$login'";
	$exe = mysql_query($sql);
	$array = mysql_fetch_row($exe); 
	mysql_close($con);
	return $array;
}

function consultScore($login){
	$con = mysql_connect('127.0.0.1', 'playercons', 'playercons');
	$db = mysql_select_db('space_multiplayer');
	$sql = "SELECT score FROM player WHERE login='$login'";
	$exe = mysql_query($sql);
	$array = mysql_fetch_row($exe); 
	//echo $array[0];
	mysql_close($con);
	return $array[0];
}

function consultTopScore(){

	$result = "";
	$con = mysql_connect('127.0.0.1', 'playercons', 'playercons');
	$db = mysql_select_db('space_multiplayer');
	$sql = "SELECT * FROM player ORDER BY score desc limit 5;";
	$exe = mysql_query($sql);
	while($array = mysql_fetch_row($exe)){
		$result .= $array[0]."-".$array[2].";";
	}
	//echo $array[0];
	mysql_close($con);
	return $result;
}

function updatePlayer($login,$score){
	$score_base = consultScore($login);
	if($score > $score_base){	
		$con = mysql_connect('127.0.0.1', 'playerupdt', 'playerupdt');
		$db = mysql_select_db('space_multiplayer');
		$sql = "UPDATE player SET score='$score' WHERE login='$login'";
		$exe_upd = mysql_query($sql);
		mysql_close($con);
		return "true";
	}else{
		return "false";
	}
}
?>