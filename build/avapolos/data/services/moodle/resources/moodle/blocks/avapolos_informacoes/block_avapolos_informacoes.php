<?php



class block_avapolos_informacoes extends block_base {

	/** @var string */
    public $blockname = null;

    /** @var bool */
    protected $contentgenerated = false;

    /** @var bool|null */
    protected $docked = null;

    /**
     * Set the initial properties for the block
     */
    function init() {
        $this->blockname = get_class($this);
        $this->title = '<b>'.get_string('pluginname', $this->blockname).'</b>';
    }
    // The PHP tag and the curly bracket for the class definition 
    // will only be closed after there is another function added in the next section.
    
    public function get_content() {
    	global $DB;

    	$infos = $DB->get_record_sql("SELECT * FROM avapolos_sync WHERE tipo = 'I' ORDER BY id DESC LIMIT 1");

		if ($this->content !== null) {
		  return $this->content;
		}
	 	
		//$roleidTeacher = $DB->get_field('role', 'id', ['shortname' => 'editingteacher']);
		$tipoInstalacao = (file_exists("/app/scripts/polo")) ? 'POLO' : 'IES'; // IES ou POLO
		$sincronizadoCom = ($tipoInstalacao == 'IES') ? 'POLO' : 'IES'; //Se for uma IES, sincronizou com o POLO, se for um POLO, sincronizou com a IES
		$dataInfo = new DateTime($infos->data);

		$this->content         =  new stdClass;
		$this->content->text   ="
			<style>
				.row-info-avapolos{
					width: 100%;
					display: inline-block;
					padding: 5px;
				}

				.row-info-avapolos p{
					margin-bottom: 0;
				}

				.row-info-avapolos div{
					float: left; width: 40%;
				}

				.back-grey{
					background-color: #F0F0F0;
				}

				.row-l{
					width: 60% !important;
				}
			</style>
			<div class='row-info-avapolos back-grey'>
				<div class='row-l'>
					<p><b>Instância:</b></p>
				</div>
				<div>
					<p>".$tipoInstalacao."</p>
				</div>
			</div>

			<div class='row-info-avapolos '>
				<hr>
				<br>
				<h5>Informações Sincronização</h5>
			</div>

			<div class='row-info-avapolos back-grey'>
				<div class='row-l'>
					<p><b>Versão:</b></p>
				</div>
				<div>
					<p>".$infos->versao."</p>
				</div>
			</div>

			<div class='row-info-avapolos'>
				<div class='row-l'>
					<p><b>Última sincronização realizada com o ".$sincronizadoCom.":</b></p>
				</div>
				<div>
					<p>".date_format($dataInfo, "d/m/Y")." às ".date_format($dataInfo, "H:i:s")."</p>
				</div>
			</div>

			<div class='row-info-avapolos back-grey'>
				<div class='row-l'>
					<p><b>Usuário:</b></p>
				</div>
				<div>
					<p>".$infos->moodle_user."</p>
				</div>
			</div>
			";

		//$this->content->footer = '<h6>Footer</h6>';
	 
		return $this->content;
	}
}
