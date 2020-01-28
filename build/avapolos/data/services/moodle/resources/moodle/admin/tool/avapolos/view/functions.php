<?php
    set_time_limit(0);

  class Connect_SSH{
    public $ip;
    public $port;
    public $login;
    public $password;
    public $sh_file;
    public $output_file;
    public $connection;

    public function __construct($ip, $port, $login, $password){
      $this->ip          = $ip;
      $this->port        = $port;
      $this->login       = $login;
      $this->password    = $password;
      $this->dirPath     = '/opt/avapolos';
      $this->sh_file     = 'sync.sh'; //Script de sincronização! Este arquivo nunca muda a menos que seja mudado também na raiz do sistema
      $this->output_file = 'sync.log'; //Arquivo de log
    }

    public function create_ssh_connection(){
      $this->connection = ssh2_connect($this->ip, 22);
      return $this->connection;
    }

    public function close_ssh_connection(){
      $this->connection = null;
      unset($this->connection);
    }

    public function exec_ssh_export($online=false,$ip="0.0.0.0"){
      // print_r($this->connection);
/* USE THIS FOR DEBUGGING
      stream_set_blocking($stream,true);
      $out=stream_get_contents($stream);
      $stderr_stream = ssh2_fetch_stream($stream, SSH2_STREAM_STDERR);
      stream_set_blocking($stderr_stream,true);
      $outerr=stream_get_contents($stderr_stream);
      stream_set_blocking($stream,false);
      exit("Output:".$out."; Error: ".$outerr);
*/
      if(ssh2_auth_password($this->connection, 'avapolos', 'avapolos')) { //CREDENCIAIS
        try{
           $extraCmd="";
          if($online) {
            $stream = ssh2_exec($this->connection, "cd ".$this->dirPath."/scripts/sync; bash setRemoteAddr.sh ".$ip.";");
            stream_set_blocking($stream,true);
            $out=stream_get_contents($stream);
            if(trim($out)=="-1"){
               exit("Impossível conectar ao servidor $ip Certifique-se de que existe conectivitade entre os servidores. <br />
               <a href=\"#\" onclick=\"location.href=document.referrer; return false;\"> Voltar </a>");
            }
          }
          $stream = ssh2_exec($this->connection, 'cd '.$this->dirPath.'/scripts/sync/; '.$extraCmd.' bash '.$this->sh_file.' '.($online?3:1).' '.$_SESSION["USER"]->username.' > '.$this->output_file);
        }catch(Exception $e){
          echo "Erro";
        }
        ssh2_exec($this->connection, 'exit');
      }else{
        die('Falha na autenticação com ip: '.$this->ip);
      }
    }

    public function exec_ssh_import(){
      // print_r($this->connection);
      if(ssh2_auth_password($this->connection, 'avapolos', 'avapolos')) { //CREDENCIAIS
        try{
           $stream = ssh2_exec($this->connection, 'cd '.$this->dirPath.'/scripts/sync;bash '.$this->sh_file.' 2 '.$_SESSION["USER"]->username.' > '.$this->output_file);
        }catch(Exception $e){
          echo "Erro";
        }
        ssh2_exec($this->connection, 'exit');
      }else{
         die('Falha na autenticação com ip: '.$this->ip);
      }
    }

    public function exec_ssh_getRemoteServerIP(){
      // print_r($this->connection);
      if(ssh2_auth_password($this->connection, 'avapolos', 'avapolos')) { //CREDENCIAIS
        try{
           $stream = ssh2_exec($this->connection, 'cat '.$this->dirPath.'/scripts/sync/variables.sh | grep remoteServerAddress | cut -d"=" -f2 | sed -e "s/\"//g" | tr "\n" " "');
            stream_set_blocking($stream,true);
            $output = stream_get_contents($stream);
            return $output;
        }catch(Exception $e){
          echo "Erro";
        }
        ssh2_exec($this->connection, 'exit');
      }else{
         die('Falha na autenticação com ip: '.$this->ip);
      }
    }

  }

?>
