var PJeOffice = {};

/**
 * Bug no JSON.stringify
 * https://github.com/mozilla/jschannel/pull/18
 */
PJeOffice.stringify = function (value) {
	var _json_stringify = JSON.stringify;	
    var _array_tojson = Array.prototype.toJSON;
    delete Array.prototype.toJSON;
    var r=_json_stringify(value);
    Array.prototype.toJSON = _array_tojson;
    return r;
};

 
/**
 * M�todo respons�vel por executar uma requisi��o ao PjeOffice.
 * @param {object} requisicao JSON com os dados da requisi��o no seguinte formato:
	var requisicao = {
		"sessao" : JSESSION_ID,
		"aplicacao" : APLICACAO_REQUISITANTE,
		"servidor" : WEB_ROOT,
		"codigoSeguranca" : CODIGO_SEGURANCA,
		"tarefaId" : 'cnj.assinador' | 'cnj.assinadorHash' | 'cnj.autenticador' | 'cnj.editor',
		"tarefa" : {
			"enviarPara" : PAGINA_QUE_RECEBERA_O_POST,
			"mensagem" : CONTEUDO_A_ASSINAR
		}
	}
 * @param {function} onSucesso fun��o executada em caso de assinatura conclu�da com sucesso
 * @param {function} onErro fun��o executada em caso de assinatura conclu�da com erro
 */
PJeOffice.executar = function(requisicao, onSucesso, onErro) {
	var imagem = new Image();
	
	// PJE OFFICE N�O EST� RODANDO NA M�QUINA DO USU�RIO
	imagem.onerror = function() {
		alert('O aplicativo PJeOffice n�o est� em execu��o em sua m�quina.');
		onErro();
	};
	
	imagem.onload = function() {
		// Imagem com 2px de largura significa que houve erro na execu��o da requisi��o		
		if (this.width == 2) {
			onErro();
		}
		else {
			// Imagem com 1px de largura significa que houve sucesso na execu��o da requisi��o
			onSucesso();
		}
	};
	requisicao.tarefa = PJeOffice.stringify(requisicao.tarefa);
	console.log(PJeOffice.stringify(requisicao.tarefa));
	console.log(PJeOffice.stringify(requisicao));
	console.log("http://localhost:8800/pjeOffice/requisicao/?r=" + encodeURIComponent(PJeOffice.stringify(requisicao)) + "&u=" + new Date().getTime());
	imagem.src = "http://localhost:8800/pjeOffice/requisicao/?r=" + encodeURIComponent(PJeOffice.stringify(requisicao)) + "&u=" + new Date().getTime();
};



/**
 * M�todo respons�vel por verificar se o PJeOffice est� em execu��o na m�quina do usu�rio.
 * @param {function} onDisponivel fun��o executada caso o PJeOffice esteja executando.
 * @param {function} onIndisponivel fun��o executada caso  o PJeOffice n�o esteja executando.
 */
PJeOffice.verificarDisponibilidade = function(onDisponivel, onIndisponivel) {        
        var imagem = new Image();
        imagem.onload = onDisponivel;
        imagem.onerror = onIndisponivel;        
        imagem.src = "http://localhost:8800/pjeOffice/?&u=" + new Date().getTime();
};

/**
 * M�todo respons�vel por fazer o login no PJe
 * @param textoAAssinar o texto que ser� assinado (atualmente, #{sessao.textoAssinatura})
 */
PJeOffice.logar = function(textoAAssinar, onSucessoLogin) {
	onFalhaLogin = function() {
		location.reload();
	}
	/** Armazena o identificador da tarefa que sera executada pelo PJeOffice
	 * Poss�veis valores:
	 * cnj.assinador
	 * cnj.assinadorHash
	 * cnj.autenticador
	 * cnj.editor */
	var tarefaId = "cnj.autenticador";
	
	var requisicao = {
		"sessao" : JSESSION_ID,
		"aplicacao" : APLICACAO_REQUISITANTE,
		"servidor" : WEB_ROOT,
		"codigoSeguranca" : CODIGO_SEGURANCA,
		"tarefaId" : tarefaId,
		"tarefa" : {
			"enviarPara" : PAGINA_LOGIN,
			"mensagem" : textoAAssinar
		}
	}
	PJeOffice.executar(requisicao, onSucessoLogin, onFalhaLogin);
}

PJeOffice.assinarHash = function(urlDocsField, onSucesso, onErro) {
	var arquivos = PJeOffice.parseToListaArquivos(urlDocsField);
	
	console.log('urlDocsField: ' + urlDocsField);
	var requisicao = {
			'sessao' : JSESSION_ID,
			'aplicacao' : APLICACAO_REQUISITANTE,
			'servidor' : WEB_ROOT,
			'codigoSeguranca' : CODIGO_SEGURANCA,
			'tarefaId' : 'cnj.assinadorHash',
			'tarefa' : {
				'algoritmoAssinatura': 'ASN1MD5withRSA',
				'uploadUrl':PAGINA_ASSINATURA,
				'modoTeste':false,
				'arquivos': arquivos
			}
		};
	
	PJeOffice.executar(requisicao, onSucesso, onErro);
};

/**
 * Transforma a string "id=1581848&codIni=153335780&md5=92a9d63176ececbb35096529f3f5dc29&isBin=false"
 * em uma lista de objeto json { id: x, codIni: x, hash: x, isBin: x } 
 */
PJeOffice.parseToListaArquivos = function(docsFields) {
	var arquivos = [];
	var itens = docsFields.split(","); 
	for (var i=0; i < itens.length; i++) {
		var itemFields = itens[i].split("&");
		if (itemFields.length == 4) {		
			arquivos[i] = {
				"id"   		: itemFields[0].substr(itemFields[0].indexOf("=") + 1),
				"codIni" 	: itemFields[1].substr(itemFields[1].indexOf("=") + 1),
				"hash" 		: itemFields[2].substr(itemFields[2].indexOf("=") + 1),
				"isBin" 	: itemFields[3].substr(itemFields[3].indexOf("=") + 1)
			}
		}
		else {
			arquivos[i] = {
				"hash" 		: itemFields[0].substr(itemFields[0].indexOf("=") + 1)
			}
		}
	}
	
	return arquivos;
}


/**
* M�todo respons�vel pela assinatura p7s
* @param nomeArquivo
*/
PJeOffice.gerarP7s = function(onSucesso, onFalha) {	
	var tarefaId = "cnj.assinador";
	
	var requisicao = {
		"sessao" 			: JSESSION_ID,
		"aplicacao"			: APLICACAO_REQUISITANTE,
		"servidor"			: WEB_ROOT,
		"codigoSeguranca"	: CODIGO_SEGURANCA,
		"tarefaId" : tarefaId,
		"tarefa" 			: {
			"modo" : "remoto",
			"tipoAssinatura" : "attached",
			"enviarPara": PAGINA_UPLOAD,
			"arquivos": [
			    {"nome": "arquivo","url": PAGINA_DOWNLOAD,"paramsEnvio": [PARAM_DEJTACTION,PARAM_MO, PARAM_CID]}
			   ]
		}
	}

	PJeOffice.executar(requisicao, onSucesso, onFalha);
}
