int M = ...;

int qC = ...;
int qP = ...;
int qB = ...;
int qVg = ...;
// ----------------------------------------------------------------------------------------------------------------------
range rC = 1..qC;
range rP = 1..qP;
range V = 1..(qC + qP);
range Vg = 1..(qVg);
range K = 1..qB;
range T = 1..1440;
// ----------------------------------------------------------------------------------------------------------------------
// Parametros
float cr[V][V] = ...; // Custo rodoviario
float cac[V][rP] = ...; // Custo de atendimento do client j pelo ponto de carga p
int ti[V][V] = ...; // Tempo trajeto ida entre i e j
int tv[V][V] = ...; // Tempo trajeto volta entre i e j
int tp[rP] = ...; // Tempo de pesagem em cada ponto de carga p
int td[V] = ...; // Tempo de descarga no cliente c
int hc[rC][Vg] = ...; // Hora de chega para cada viagem do cliente
float vc[rC][Vg] = ...; // Volume de material solicitado pelo cliente em cada viagem 
int qv[V] = ...; // Quantidade de viagens para cada cliente
int kp[rP] = ...; // Quantidade veiculos disponiveis por central
// ----------------------------------------------------------------------------------------------------------------------
// Variaveis decisao
dvar boolean x[K][rP][V][V][Vg]; // Se a rota de i para j é percorrida pelo veiculo k da central p para antender a viagem v
dvar float qmc[K][rP][V]; 
dvar float qme[K][rP][V][Vg]; // Quanto material o caminhao k da central p entrega no cliente c 
dvar int hp[K][V][Vg]; // Hora de pesagem da viagem v para atendimento do cliente c para a viagem v
dvar int hsac[K][rP][V][Vg]; // Hora de saida do veiculo k para atendimento do cliente c para a viagem v
dvar int hiac[K][rP][V][Vg]; // Hora de início do atendimento do cliente c pelo veiculo k para a viagem v
dvar int hfac[K][rP][V][Vg]; // Hora de final do atendimento do cliente c pelo veiculo k para a viagem v
dvar int hcpc[K][rP][V][Vg]; // Hora de chegada no ponto de carga do atendimento do cliente c pelo veiculo k para a viagem v
// ----------------------------------------------------------------------------------------------------------------------
// Modelo 

minimize sum(i in V, j in V, k in K, p in rP, v in Vg)(x[k][p][i][j][v] * cr[i][j]) + 
	sum(i in V, j in V, k in K, p in rP, v in Vg: j > qP)( x[k][p][i][j][v] * cac[j][p]);

subject to {
	SeChegarEmUmClienteTemQueSair:
	forall(j in V : j > qP){
		sum(i in V, k in K, p in rP, v in Vg)(x[k][p][i][j][v]) - 
			sum(i in V, k in K, p in rP, v in Vg)(x[k][p][j][i][v]) == 0;	
	}
	QuantidadeDeViagensQueChegamEmUmClienteTemQueSerIgualAQuantidadeSolicitada:
	forall(c in V : c > qP){
		sum(i in V, k in K, p in rP, v in Vg)(x[k][p][i][c][v]) == qv[c];
	}
	DemandaDeCadaClienteDeveSerAtendida:
	forall(k in K, p in rP, i in V, c in V, v in Vg : c > qP){
		  x[k][p][i][c][v] * qme[k][p][i][c] == vc[c][v];	
	}
	EvitarSubTour:
	forall(k in K, p in rP, i in V, c in V, v in Vg : c > qP){
		x[k][p][i][c][v] * (qmc[k][p][c] - qmc[k][p][i] + qme[k][p][i][c]) <= 0;	
	}
	QuantidadeDeMaterialQueCaminhaoCarregaQuandoChegaNoPontoCargaEhZero:
	forall(k in K, p in rP, i in V, c in V, v in Vg : c > qP && i <= qP){
		x[k][p][c][i][v] * (qmc[k][p][c]) <= 0;	
	}
	QuantidadeDeMaterialEntreguePontosCargaEhZero:
	CaminhaoNaoTrafegaEntreBases:
	QuantidadeCaminhaoSaiBaseTemQueSerMenorIgualQuantidadeDisponivel:
	SeCaminhaoSaiDoPontoCargaTemQuePossuirMaterialDasViagensQueVaiAtender:
	SeCaminhaoChegaEmClienteTemQuePossuirMaterialSolicitadoPeloCliente:
	RestricoesDeJanelaDeTempoParaCadaCliente:
	forall(k in K, p in rP, i in V, c in V, v in Vg : c > qP) {
		x[k][p][i][c][v] * (hiac[k][p][c][v] - hc[c][v]) == 0;
		x[k][p][i][c][v] * (hp[k][c][v] + tp[p] + ti[i][c] - hiac[k][p][c][v]) == 0;
		x[k][p][i][c][v] * (hiac[k][p][c][v] + td[c] - hfac[k][p][c][v]) == 0;
		x[k][p][i][c][v] * (hfac[k][p][c][v] + tv[c][i] - hcpc[k][p][c][v]) == 0;
	}
}
