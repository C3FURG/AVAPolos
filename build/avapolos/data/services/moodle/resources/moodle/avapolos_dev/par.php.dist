<?php
//-------------------- AJUSTES MOODLE IES PAR --------------------------
ini_set('display_errors', 1); ini_set('display_startup_errors', 1); error_reporting(E_ALL);
$i = 0; //DEGUB
$dsn = "pgsql:host=db_moodle_ies;dbname=moodle;user=moodle;password=$DB_MOODLE_MOODLE_PASSWORD";
try{
	$conn = new PDO($dsn);
  $updateValue = array();
  $sequencias  = array();
  if($conn){
  	echo "<p style='color:green'>Conectado na base de dados <strong>MOODLE IES</strong> com sucesso!<br></p>";
  	echo "<table>";
			echo" <tr>";
			echo" 	<th style='color:#ff5252'> --Tipo Sequencia--</th>";
			echo" 	<th style='color:#ea80fc'> --------- Nome da Sequencia ---------</th>";
			echo" 	<th style='color:#1976d2'> ---------- Valor Atual da Sequencia --------- </th>";
			echo" 	<th style='color:#009688'> ----------  Nova Sequencia  ----------</th>";
			echo" 	<th style='color:purple'>  Increment </th>";
			echo" 	<th style='color:#fb8c00'>Correcao Sequencia </th>";
			echo" </tr>";
			$sql = "SELECT * FROM information_schema.sequences";
			$res = $conn->query($sql);
			$conn->beginTransaction();
			foreach ( $res as $row ) {
				echo" <tr>";
				if($row['sequence_name'] != "bdr_conflict_history_id_seq"){
					$sequencias = $row['sequence_name'];
				/*
					CONTROLE DOS ULTIMOS VALOR/INDICE DE CADA TABELA. SE FOR PAR, É NECESSÁRIO DEIXAR TODOS
					OS INDICES COMO PAR, O MESMO OCORRENDO CASO FOREM IMPAR
				*/
					$sql2 = "SELECT last_value FROM ".$row['sequence_name'].";"; //BUSCANDO OS ULTIMOS INDICES DE CADA TABELA
					$result = $conn->query($sql2);
			    $result = $result->fetchAll(PDO::FETCH_ASSOC);
			    if(($result[0]['last_value'] % 2) == 0){ //DEIXANDO TUDO PAR, PARA O CASO MOODLE-IES
			    	$val = $result[0]['last_value'] + 2;
			    }else{
			    	$val = $result[0]['last_value'] + 1;
			    }

				// // ----------------------------ALTERANDO A SEQUENCIA PARA PAR ------------------------------------------------//
				 	$sql3 = "ALTER SEQUENCE ".$row['sequence_name']." INCREMENT BY 2;";
				 	$valor_correcao = $conn->query($sql3);
				 	$valor_correcao = $valor_correcao->fetchAll(PDO::FETCH_ASSOC);




				// //----------------------------AJUSTANDO O VALOR DO INDICE   ------------------------------------------------//
					$sql4 = "SELECT setval('".$row['sequence_name']."',".$val.", true);";
				 	$valor_correcao2 = $conn->query($sql4);

					echo"<td style='color:#ff5252'>". ++$i." - Par</td><td style='color:#ea80fc'>".$row['sequence_name']."</td> 	<td style='color:#1976d2'>".$result[0]['last_value']."</td><td style='color:#009688'>".$val."</td><td style='color:purple'>".$row['increment']."</td><td style='color:#fb8c00'>  SELECT setval('".$row['sequence_name']."',".$val.", true);</td>";
				// 	// $valor_correcao2 = $valor_correcao->fetchAll(PDO::FETCH_ASSOC);
				}
			echo" </tr>";
			}
		echo "</table>";
  }
}catch (PDOException $e){
	// mesnagem de error
echo $e->getMessage();
}

?>
