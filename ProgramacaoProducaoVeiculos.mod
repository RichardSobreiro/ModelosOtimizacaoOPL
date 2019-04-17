int qViagens = ...; // Quantidade de viagens
int qPontosCarga = ...; // Quantidade de pontos de carga que podem produzir concreto para atendimento das viagens
int qBetoneiras = ...; // Quantidade de betoneiras
int M = ...;
// Conjuntos

range I = 1..qViagens;
range K = 1..qPontosCarga;
range B = 1..qBetoneiras;

// Parâmetros

float dp[I][K] = ...; // Tempo gasto para pesagem da viagem v no ponto de carga p
float dv[I][K] = ...; // Tempo gasto no trajeto entre o ponto de carga p e o cliente da viagem i
float td[I] = ...; // Tempo de descarga no cliente da viagem v
float tmaxvc[I] = ...; // Tempo maximo vida do concreto da viagem v
float hs[I] = ...; // Horario solicitado pelo cliente para chegada da viagem v

float c[I][K] = ...; // Custo de atendimento da viagem v pelo ponto de carga p (Custo dos insumos + Custo rodoviário + Custo de pessoal)
int qvMax[K] = ...; // Quantidade de viagens que cada ponto de carga p pode atender por dia
float cuve[K] = ...; // Custo de atendimento de viagem extra

// Variáveis 

dvar float tfp[I]; // Instante final da pesagem da viagem v
dvar float tfb[I]; // Instante final de antedimento da viagem v
dvar float hcc[I]; // Horario de chegada no cliente
dvar boolean x[I][I][K]; // Se a viagem v precede imediatamente a viagem v no ponto de carga p
dvar boolean y[I][I][B]; // Se a betoneira b atende a viagem j após a viagem i

dvar float atrc[I]; // Atraso da viagem v
dvar float avnc[I]; // Avanço da viagem v
dvar float atrp[I]; // Atraso na pesagem da viagem v
dvar float avnp[I]; // Avanço na pesagem da viagem v

dvar boolean vp[I][K]; // Se a viagem v é atendida pelo ponto de carga p
dvar int qve[K]; // Custo de atendimento de viagens extras

// Modelo

minimize sum(v in I)(atrc[v] + avnc[v] + atrp[v] + avnp[v]) + 
	sum(v in I, p in K)((vp[v][p] * c[v][p]) + (cuve[p] * qve[p]));

subject to {
	TodaViagemDeveSerAlocadaParaUmPontoDeCarga:
	forall(v in I){
		sum(p in K)(vp[v][p]) >= 1;
		sum(p in K)(vp[v][p]) <= 1;	
	}
	SeMaisViagensQueACapacidadeDoPontoCargaSaoAtendidasCustoDeveSerPago:
	forall(p in K){
		qve[p] >= qvMax[p] - sum(v in I)(vp[v][p]);
	}
	ViagemNaoPodeSucederElaMesmaNaPesagem:
	forall(i in I, j in I, k in K : i == j){
		x[i][j][k] <= 0;					
	}
	TodaViagemDeveSucederAlgumaViagemNaPesagemExcetoAPrimeira:
	forall(v in I : v > 1){
		sum(p in K, i in I)(x[i][v][p]) >= 1;
		sum(p in K, i in I)(x[i][v][p]) <= 1;
	}
	ViagemFicticia1AntecedeAlgumaViagemEmCadaPontoDeCarga:
	forall(p in K){
		sum(v in I : v > 1)(x[1][v][p]) >= 1;
		sum(v in I : v > 1)(x[1][v][p]) <= 1;
	}
	TodaViagemDeveSucederApenasUmaViagemEmUmaBetoneiraExcetoAPrimeira:
	forall(v in I : v > 1) {
		sum(b in B, i in I)(y[i][v][b]) >= 1;
		sum(b in B, i in I)(y[i][v][b]) <= 1;
	}
	ViagemFicticia1AntecedeAlgumaViagemEmCadaBetoneira:
	forall(b in B) {
		sum(v in I : v > 1)(y[1][v][b]) >= 1;
		sum(v in I : v > 1)(y[1][v][b]) <= 1;
	}
	SomatorioDasViagensQueAntecedemUmaViagemNaPesagemEmUmPontoDeCargaDeveSerIgualAoSomatorioDasViagensQueSucedem:	
	forall(h in I, p in K : h > 1){
		sum(i in I : i != h)(x[i][h][p]) - sum(j in I : j != h)(x[h][j][p])	>= 0;
		sum(i in I : i != h)(x[i][h][p]) - sum(j in I : j != h)(x[h][j][p])	<= 0;
	}
	SomatorioDasViagensQueAntecedemUmaViagemEmUmaBetoneiraDeveSerIgualAoDasQueSucedem:
	forall(h in I, b in B : h > 1){
		sum(i in I : i != h)(y[i][h][b]) - sum(j in I : j != h)(y[h][j][b])	>= 0;
		sum(i in I : i != h)(y[i][h][b]) - sum(j in I : j != h)(y[h][j][b])	<= 0;
	}
	SequenciamentoDePesagemDeBetoneirasNoMesmoPontoDeCarga:
	forall(i in I, j in I : j > 1){
		tfp[j] >= tfp[i] + 
			sum(p in K)(vp[j][p] * dp[j][p]) + 
			(M * (sum(p in K)(x[i][j][p]) - 1));
	}
	GarantiaTempoDeVidaDoConcreto:
	forall(j in I){
		hs[j] - tfp[j] <= tmaxvc[j];
	}
	SequenciamentoDoAtendimentoDeViagensPelaMesmaBetoneira:
	forall(i in I, j in I: j > 1){
		tfb[j] >= tfb[i] + 
			sum(p in K)(vp[j][p] * dp[j][p]) + 
			(2 * sum(p in K)(vp[j][p] * dv[j][p])) + 
			td[j] +  
			(M * (sum(b in B)(y[i][j][b]) - 1));	
		hcc[j] >= tfb[j] - sum(p in K)(vp[j][p] * (dv[j][p] + td[j]));
		hcc[j] <= tfb[j] - sum(p in K)(vp[j][p] * (dv[j][p] + td[j]));
	}
	SeAViagemSucedeAlgumaViagemEmUmPontoDeCargaElaDeveSerAtribuidaAoPontoDeCarga:
	forall(v in I, p in K){
		M * vp[v][p] >= sum(i in I)(x[i][v][p]);	
	}
	
	AtrasoAvancoDasVaigens:
	forall(i in I){
		atrc[i] >= hcc[i] - hs[i];
		avnc[i] >= hs[i] - hcc[i];
		atrp[i] >= hcc[i] - sum(p in K)((dv[i][p] + dp[i][p]) * vp[i][p]) - tfp[i];
		avnc[i] >= sum(p in K)((dv[i][p] + dp[i][p]) * vp[i][p]) + tfp[i] - hcc[i]; 
	}
	NaoNegatividadeDasVariaveisReais:
	forall(i in I){
		atrc[i] >= 0;
		avnc[i] >= 0;
		atrp[i] >= 0;
		avnp[i] >= 0;
		tfp[i] >= 0;
		tfb[i] >= 0;
		hcc[i] >= 0;
	}
	NaoNegatividade:
	forall(p in K){
		qve[p] >= 0;
	}
}

tuple Viagem {
	key float horarioFinalAtendimento;
	int viagem;
	int viagemAtecessorPesagem;
	int pontoCarga;
	key int betoneira;
	float horarioFinalPesagem;
	float horarioSolicitado;
	float atraso;
	float avanco;
};

tuple Pesagem {
	int pontoCarga;
	int viagem;
	key float horarioFinalPesagem;
};

sorted {Viagem} Viagens = {};
sorted {Pesagem} Pesagens = {}; 

execute {
	for(var i in I){
		for(var j in I){
			for(var p in K){
				if(x[i][j][p] == 1){
					Pesagens.add(p, j, tfp[j]);							
				}			
			}		
		}	
	}

	for(var i in I){
		for(var j in I){
			for(var b in B){
				if(y[i][j][b] == 1){
					for(var ii in I){
						for(var p in K){
							if(vp[j][p] == 1){
								Viagens.add(tfb[j], j, i, p, b, tfp[j], hs[j], atrc[j], avnc[j]);							
							}							
						}					
					}								
				}			
			}		
		}	
	}
	
	writeln("-------------------------------------------------------------------");
	for(var b in B){
		writeln("TRAJETO BETONEIRA ", b);
		for(var viagem in Viagens){
			if(viagem.betoneira == b){
				writeln("-------------------------------------------------------------------");			
				writeln("VIAGEM ", viagem.viagem);
				writeln("Inicio: ", tfp[viagem.viagem] - dp[viagem.viagem][viagem.pontoCarga]);tfb
				writeln("Fim: ", tfb[viagem.viagem]);
				writeln("Horario Solicitado: ", hs[viagem.viagem]);
				writeln("Horario Real: ", hcc[viagem.viagem]);	
				writeln("Horario Real Final de Pesagem: ", tfp[viagem.viagem]);
				writeln("Horario Otimo Final de Pesagem: ", hs[viagem.viagem] - dv[viagem.viagem][viagem.pontoCarga] - dp[viagem.viagem][viagem.pontoCarga]);
				writeln("Atraso Pesagem: ", atrp[viagem.viagem]);
				writeln("Avanco Pesagem: ", avnp[viagem.viagem]);
				writeln("Atraso Chegada Cliente: ", atrc[viagem.viagem]);
				writeln("Avanco Chegada Cliente: ", avnc[viagem.viagem]);
				writeln("-------------------------------------------------------------------");		
			}		
		}
	}
	writeln("-------------------------------------------------------------------");
	
	/*for(var p in K){
		writeln("-------------------------------------------------------------------");	
		writeln("PONTO CARGA ", p);
		for(var pesagem in Pesagens){
			if(pesagem.pontoCarga == p){
				writeln("Viagem ", pesagem.viagem, " finaliza pesagem as ", pesagem.horarioFinalPesagem);								
			}						
		}
		writeln("-------------------------------------------------------------------");		
	}
	writeln("-------------------------------------------------------------------");
	for(var b in B){
		writeln("TRAJETO BETONEIRA ", b);
		for(var viagem in Viagens){
			if(viagem.betoneira == b){
				writeln("-------------------------------------------------------------------");			
				writeln("VIAGEM ", viagem.viagem);
				writeln("Horario Real Final de Pesagem: ", tfp[viagem.viagem]);
				writeln("Horario Otimo Final de Pesagem: ", hs[viagem.viagem] - dv[viagem.viagem][viagem.pontoCarga]);
				writeln("Horario Solicitado: ", hs[viagem.viagem]);
				writeln("Horario Real: ", hcc[viagem.viagem]);	
				writeln("Atraso Pesagem: ", atrp[viagem.viagem]);
				writeln("Avanco Pesagem: ", avnp[viagem.viagem]);
				writeln("Atraso Chegada Cliente: ", atrc[viagem.viagem]);
				writeln("Avanco Chegada Cliente: ", avnc[viagem.viagem]);
				
				writeln("-------------------------------------------------------------------");		
			}		
		}
	}
	writeln("-------------------------------------------------------------------");*/
	
}



