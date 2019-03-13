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
float cuc[K] = ...; // Custo de uso do caminhao k
int ti[V][V] = ...; // Tempo trajeto ida entre i e j
int tv[V][V] = ...; // Tempo trajeto volta entre i e j
int tp[rP] = ...; // Tempo de pesagem em cada ponto de carga p
int td[V] = ...; // Tempo de descarga no cliente c
int hc[V][Vg] = ...; // Hora de chega para cada viagem do cliente
float vc[V][Vg] = ...; // Volume de material solicitado pelo cliente em cada viagem 
int qv[V] = ...; // Quantidade de viagens para cada cliente
int kp[rP] = ...; // Quantidade veiculos disponiveis por central
// ----------------------------------------------------------------------------------------------------------------------
// Variaveis decisao
dvar boolean x[K][rP][V][V][Vg]; // Se a rota de i para j é percorrida pelo veiculo k da central p para antender a viagem v
//dvar float qmc[K][rP][V]; // Quantidade de material que o caminhao carrega
//dvar float qme[K][rP][V][Vg]; // Quanto material o caminhao k da central p entrega no cliente c 
dvar int hp[K][V][Vg]; // Hora de pesagem da viagem v para atendimento do cliente c para a viagem v
dvar int hsac[K][rP][V][Vg]; // Hora de saida do veiculo k para atendimento do cliente c para a viagem v
dvar int hiac[K][rP][V][Vg]; // Hora de início do atendimento do cliente c pelo veiculo k para a viagem v
dvar int hfac[K][rP][V][Vg]; // Hora de final do atendimento do cliente c pelo veiculo k para a viagem v
dvar int hcpc[K][rP][V][Vg]; // Hora de chegada no ponto de carga do atendimento do cliente c pelo veiculo k para a viagem v
dvar boolean cu[K][rP][T]; // Caminhão k do ponto de carga p está sendo usado no instante de tempo t
// ----------------------------------------------------------------------------------------------------------------------
// Modelo 

execute PARAMS {
  cplex.tilim = 100;
}

minimize sum(k in K, p in rP, i in V, j in V, v in Vg)(x[k][p][i][j][v] * (cr[i][j] + cac[j][p])) + 
	sum(k in K, p in rP, t in T)(cu[k][p][t] * cuc[k]);

subject to {
	SeChegarEmUmClienteTemQueSair:
	forall(c in V : c > qP){
		sum(k in K, p in rP, i in V, v in Vg)(x[k][p][i][c][v]) - 
			sum(k in K, p in rP, i in V, v in Vg)(x[k][p][c][i][v]) == 0;	
	}
	QuantidadeDeViagensQueChegamEmUmClienteTemQueSerIgualAQuantidadeSolicitada:
	forall(c in V : c > qP){
		sum(k in K, p in rP, i in V, v in Vg : i <= qP)(x[k][p][i][c][v]) == qv[c];
	}
	EvitarSubTourQueNaoPassamPorPontosDeCarga:
	/*forall(k in K, p in rP, i in V, c in V, v in Vg : c > qP && i > qP && i != c){
		qmc[k][p][c] - qmc[k][p][i] + qme[k][p][i][c] >= (1 - x[k][p][i][c][v]) * M;	
	}*/
	QuantidadeDeMaterialEntreguePontosCargaEhZero: // Necessária ?
	CaminhaoNaoTrafegaEntreBases:
	forall(j in V : j <= qP){
		sum(k in K, p in rP, i in V, v in Vg : i <= qP)(x[k][p][i][j][v]) == 0;
	}
	RestricoesDeJanelaDeTempoParaCadaCliente:
	forall(k in K, p in rP, i in V, c in V, v in Vg : c > qP) {
		hiac[k][p][c][v] - hc[c][v] >= (1 - x[k][p][i][c][v]) * M;
		hp[k][c][v] + tp[p] + ti[i][c] - hiac[k][p][c][v] >= (1 - x[k][p][i][c][v]) * M;
		hiac[k][p][c][v] + td[c] - hfac[k][p][c][v] >= (1 - x[k][p][i][c][v]) * M;
		hfac[k][p][c][v] + tv[c][i] - hcpc[k][p][c][v] >= (1 - x[k][p][i][c][v]) * M;
	}
	QuantidadeCaminhaoSaiBaseTemQueSerMenorIgualQuantidadeDisponivel:
	forall(k in K, p in rP, c in V, v in Vg, t in T : c > qP){
		(hp[k][c][v] <= t) && (t <= hcpc[k][p][c][v]) => cu[k][p][t] >= 1;
	}
	forall(p in rP, t in T){
		sum(k in K)(cu[k][p][t]) <= kp[p];	
	}
	//SeCaminhaoSaiDoPontoCargaTemQuePossuirMaterialDasViagensQueVaiAtender:
	//SeCaminhaoChegaEmClienteTemQuePossuirMaterialSolicitadoPeloCliente:
	NaoNegatividadeDasVariaveis:
	forall(k in K, p in rP, i in V, j in V, v in Vg){
		//qmc[k][p][v] >= 0;
		//qme[k][p][i][v] >= 0;
		hp[k][i][v] >= 0;
		hsac[k][p][i][v] >= 0;
		hiac[k][p][i][v] >= 0;
		hfac[k][p][i][v] >= 0;
		hcpc[k][p][i][v] >= 0;
	}
}
