int qViagens = ...; // Quantidade de viagens
int qPontosCarga = ...; // Quantidade de pontos de carga que podem produzir concreto para atendimento das viagens
int qBetoneiras = ...; // Quantidade de betoneiras
int M = ...;
// Conjuntos

range I = 1..qViagens;
range K = 1..qPontosCarga;
range B = 1..qBetoneiras;

// Par�metros

float dp[I][K] = ...; // Tempo gasto para pesagem da viagem v no ponto de carga p
float dv[I][K] = ...; // Tempo gasto no trajeto entre o ponto de carga p e o cliente da viagem i
float td[I] = ...; // Tempo de descarga no cliente da viagem v
float tmaxvc[I] = ...; // Tempo maximo de vida do concreto da viagem v
float hs[I] = ...; // Horario solicitado pelo cliente para chegada da viagem v

float f[I][K] = ...; // Faturamento pelo atendimento da viagem v pelo ponto de carga p (Custo dos insumos + Custo rodovi�rio + Custo de pessoal)
float c[I][K] = ...; // Custo de atendimento da viagem v pelo ponto de carga p (Custo dos insumos + Custo rodovi�rio + Custo de pessoal)
float cnv[I] = ...; // Custo de n�o atendimento da viagem v
float qvMax[K] = ...; // Quantidade de viagens que cada ponto de carga p pode atender por dia
float cuve[K] = ...; // Custo de atendimento de viagem extra
float pb[K][B] = ...; // Se a betoneira b pertence ao ponto de carga p

// Vari�veis 

dvar float tfp[I]; // Instante final da pesagem da viagem v
dvar float tfb[I]; // Instante final de antedimento da viagem v
dvar float hcc[I]; // Horario de chegada no cliente
dvar boolean x[I][I][K]; // Se a viagem j precede imediatamente a viagem v no ponto de carga p
dvar boolean y[I][I][B]; // Se a betoneira b atende a viagem j ap�s a viagem i

dvar float atrc[I]; // Atraso da viagem v
dvar float avnc[I]; // Avan�o da viagem v
dvar float atrp[I]; // Atraso na pesagem da viagem v
dvar float avnp[I]; // Avan�o na pesagem da viagem v

dvar boolean vp[I][K]; // Se a viagem v � atendida pelo ponto de carga p
dvar boolean vb[I][B]; // Se a viagem v � atendida pela betoneira b
dvar float qve[K]; // Custo de atendimento de viagens extras
dvar float ctnv; // Custo total de n�o atendimento de viagens

dvar float v[I][B];

dvar float teste;
dvar float teste1;

// Modelo

maximize 
	//sum(v in I)(atrc[v] + avnc[v] + atrp[v] + avnp[v]) + 
	sum(v in I, p in K)((vp[v][p] * (f[v][p] - c[v][p])));
	//+ ctnv 
	//+ (cuve[p] * qve[p])); 

subject to {
	/*CustoTotalNaoAtendimentoDeViagens:
	forall(v in I){
		ctnv >= sum(p in K, b in B)(((1 - vp[v][p]) * cnv[v]) + ((1 - vb[v][b]) * cnv[v]));		
	}*/
	/*SeMaisViagensQueACapacidadeDoPontoCargaSaoAtendidasCustoDeveSerPago:
	forall(p in K){
		qve[p] >= sum(v in I)(vp[v][p]) - qvMax[p];
	}*/
	ViagemNaoPodeSucederElaMesmaNaPesagem:
	forall(i in I, j in I, k in K : i == j){
		x[i][j][k] <= 0;					
	}
	ViagemNaoPodeSucederElaMesmaNaBetoneira:
	forall(i in I, j in I, b in B : i == j){
		y[i][j][b] <= 0;					
	}
	TodaViagemDeveAntecederSucederNoMaximoAlgumaViagemNaPesagemExcetoAPrimeira:
	forall(p in K, v in I){
		//sum(i in I : i != v)(x[i][v][p]) >= 1;
		sum(i in I)(x[i][v][p]) <= 1;
		sum(i in I)(x[v][i][p]) <= 1;
		sum(i in I)(x[v][i][p]) <= sum(i in I)(x[i][v][p]);
		sum(i in I)(x[v][i][p]) >= sum(i in I)(x[i][v][p]);
	}
	TodaViagemDeveAntecederSucederNoMaximoApenasUmaViagemEmUmaBetoneiraExcetoAPrimeira:
	forall(b in B, v in I) {
		//sum(b in B, i in I)(y[i][v][b]) >= 1;
		sum(i in I)(y[i][v][b]) <= 1;
		sum(i in I)(y[v][i][b]) <= 1;
		sum(i in I)(y[v][i][b]) <= sum(i in I)(y[i][v][b]);
		sum(i in I)(y[v][i][b]) >= sum(i in I)(y[i][v][b]);
	}
	Teste:
	teste == sum(i in I)(y[7][i][1]);
	teste1 == sum(i in I)(y[i][7][1]);
	ViagemFicticia1AntecedeNoMaximoAlgumaViagemEmCadaPontoDeCarga:
	forall(p in K){	
		//sum(v in I : v > 1)(x[1][v][p]) >= 1;
		sum(v in I : v > 1)(x[1][v][p]) <= 1;
	}
	ViagemFicticia1AntecedeNoMaximoAlgumaViagemEmCadaBetoneira:
	forall(b in B) {
		//sum(v in I : v > 1)(y[1][v][b]) >= 1;
		sum(v in I : v > 1)(y[1][v][b]) <= 1;
	}
	SequenciamentoDePesagemDeBetoneirasNoMesmoPontoDeCarga:
	forall(p in K, i in I, j in I : j > 1){
		(M * ( 1 - (x[i][j][p]))) + tfp[j] >= 
			tfp[i] + 
			sum(p in K)(vp[j][p] * dp[j][p]);
	}
	GarantiaTempoDeVidaDoConcreto:
	forall(j in I){
		hs[j] - tfp[j] <= tmaxvc[j];
	}
	SequenciamentoDoAtendimentoDeViagensPelaMesmaBetoneira:
	forall(b in B, i in I, j in I: j > 1){
		(M * (1 - y[i][j][b])) + tfb[j] >= tfb[i] + 
			sum(p in K)(vp[j][p] * (dp[j][p] + (2 * dv[j][p]))) + 
				td[j];	
			
		hcc[j] >= tfb[j] - sum(p in K)(vp[j][p] * dv[j][p]) - td[j];
		hcc[j] <= tfb[j] - sum(p in K)(vp[j][p] * dv[j][p]) - td[j];
	}
	EliminarSubTours:
	forall(b in B, j in I : j > 1) {
		forall(i in I :i != j) {
			M * y[i][j][b] <= v[j][b] - v[i][b] - 1 + M;
		}
	}
	SeAViagemSucedeAlgumaViagemEmUmPontoDeCargaElaDeveSerAtribuidaAoPontoDeCarga:
	forall(v in I, p in K){
		vp[v][p] >= sum(i in I)(x[i][v][p]);
		vp[v][p] <= sum(i in I)(x[i][v][p]);	
	}
	SeAViagemEhAtendidaPelaBetoneiraAposAlgumaViagemEssaViagemSoPodeSerAtendidaPorEssaBetoneira:
	forall(v in I, b in B){
		vb[v][b] >= sum(i in I)(y[i][v][b]);
		vb[v][b] <= sum(i in I)(y[i][v][b]);	
	}
	AtribuicaoViagemBetoneiraPontoCarga:
	/*forall(b in B, p in K, v in I){
		//vb[v][b] + vp[v][p] <= 2 * pb[p][b];
		//vb[v][b] + vp[v][p] >= 2 * pb[p][b];
	}*/
	/*TodaViagemDeveSerAlocadaParaUmPontoDeCarga:
	forall(v in I){
		sum(p in K)(vp[v][p]) >= 1;
		sum(p in K)(vp[v][p]) <= 1;	
	}*/
	AtrasoAvancoDasVaigens:
	forall(i in I){
		sum(b in B)(vb[i][b]) >= sum(p in K)(vp[i][p]);
		sum(b in B)(vb[i][b]) <= sum(p in K)(vp[i][p]);
		
		sum(b in B)(vb[i][b]) <= sum(p in K)(vp[i][p]);
	
		atrc[i] >= hcc[i] - hs[i];
		atrc[i] <= hcc[i] - hs[i];
		
		avnc[i] >= hs[i] - hcc[i];
		avnc[i] <= hs[i] - hcc[i];
		
		atrp[i] >= hcc[i] - sum(p in K)((dv[i][p] + dp[i][p]) * vp[i][p]) - tfp[i];
		atrp[i] <= hcc[i] - sum(p in K)((dv[i][p] + dp[i][p]) * vp[i][p]) - tfp[i];
		
		avnc[i] >= sum(p in K)((dv[i][p] + dp[i][p]) * vp[i][p]) + tfp[i] - hcc[i]; 
		avnc[i] <= sum(p in K)((dv[i][p] + dp[i][p]) * vp[i][p]) + tfp[i] - hcc[i];
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
		forall(b in B){
			v[i][b] >= 0;		
		}
	}
	NaoNegatividade:
	forall(p in K){
		qve[p] >= 0;
	}
}

tuple Viagem {
	float horarioFinalAtendimento;
	int viagem;
	int viagemAtecessorPesagem;
	int pontoCarga;
	int betoneira;
	float horarioFinalPesagem;
	float horarioSolicitado;
	float atraso;
	float avanco;
};

sorted {Viagem} Viagens = {};

execute {
	writeln("Viagem betoneira 7: ", vb[7][1]);
	writeln("Viagem ponto carga 7: ", vp[7][1]);
	writeln("Antecede 7: ", teste);
	writeln("Sucede 7: ", teste1);
	
	for(var i in I){
		for(var j in I){
			for(var p in K){
				if(x[i][j][p] == 1){
					writeln("Viagem ",j, " sucede viagem ", i, " no pc ",p);								
				}			
			}		
		}	
	}
	writeln("-------------------------------------------------------------------");
	for(var i in I){
		for(var j in I){
			for(var b in B){
				if(y[i][j][b] == 1){
					writeln("Viagem ",j, " sucede viagem ", i, " na betoneira ",b);
					//writeln("v[",i,"][",b,"]  = ",v[i][b], " e v[",j,"][",b,"]  = ",v[j][b]);
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

	/*for(var i in I){
		for(var j in I){
			for(var b in B){
				if(y[i][j][b] == 1){
					writeln("Viagem ",j, " sucede viagem ", i, " na betoneira ",b);
					//writeln("v[",i,"][",b,"]  = ",v[i][b], " e v[",j,"][",b,"]  = ",v[j][b]);
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
	}*/
	/*writeln("-------------------------------------------------------------------");
	for(var i in I){
		for(var j in I){
			for(var b in B){
				if(y[i][j][b] == 1){
					writeln("Viagem ",i, " antecede viagem ", j, " na betoneira ",b);								
				}			
			}		
		}	
	}
	writeln("-------------------------------------------------------------------");
	for(var i in I){
		for(var j in I){
			for(var p in K){
				if(x[i][j][p] == 1){
					writeln("Viagem ",i, " antecede viagem ", j, " no ponto de carga ",p);					
				}							
			}
		}	
	}
	writeln("-------------------------------------------------------------------");
	for(var i in I){
		for(var j in I){
			for(var p in K){
				if(x[i][j][p] == 1){
					writeln("Viagem ",j, " sucede viagem ", i, " no ponto de carga ",p);					
				}							
			}
		}	
	}*/
	writeln("-------------------------------------------------------------------");
	for(var b in B){
		writeln("TRAJETO BETONEIRA ", b);
		for(var viagem in Viagens){
			if(viagem.betoneira == b && (viagem.viagem == 3 || viagem.viagem == 4)){
				writeln("-------------------------------------------------------------------");			
				writeln("VIAGEM ", viagem.viagem);
				writeln("PontoCarga: ", viagem.pontoCarga);
				writeln("Betoneira: ", viagem.betoneira);
				writeln("PontoCarga da Betoneira: ", pb[viagem.pontoCarga][viagem.betoneira]);
				writeln("Inicio: ", tfb[viagem.viagem] - (2*dv[viagem.viagem][viagem.pontoCarga]) - dp[viagem.viagem][viagem.pontoCarga] - td[viagem.viagem]);
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
	
}

execute {
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


	var f = new IloOplOutputFile("C:\\ArtigoSBPO\\API.ArtigoSBPO\\ResultFile\\Result.json");
	f.writeln("{");
	f.writeln("	\"viagens\": [");
	for(var b in B){
		for(var viagem in Viagens){
			if(viagem.betoneira == b){
				f.writeln("	{");
				f.writeln("		\"Betoneira\": ", viagem.betoneira, ",");			
				f.writeln("		\"Viagem\": ", viagem.viagem, ",");
				f.writeln("		\"PontoCarga\": ", viagem.pontoCarga, ",");
				f.writeln("		\"Inicio\": ", tfp[viagem.viagem] - dp[viagem.viagem][viagem.pontoCarga], ",");
				f.writeln(" 	\"Fim\": ", tfb[viagem.viagem], ",");
				f.writeln(" 	\"HorarioSolicitado\": ", hs[viagem.viagem], ",");
				f.writeln(" 	\"HorarioReal\": ", hcc[viagem.viagem], ",");	
				f.writeln(" 	\"HorarioRealFinalPesagem\": ", tfp[viagem.viagem], ",");
				f.writeln(" 	\"HorarioOtimoFinalPesagem\": ", hs[viagem.viagem] - dv[viagem.viagem][viagem.pontoCarga] - dp[viagem.viagem][viagem.pontoCarga], ",");
				f.writeln(" 	\"AtrasoPesagem\": ", atrp[viagem.viagem], ",");
				f.writeln(" 	\"AvancoPesagem\": ", avnp[viagem.viagem], ",");
				f.writeln(" 	\"AtrasoChegadaCliente\": ", atrc[viagem.viagem], ",");
				f.writeln(" 	\"AvancoChegadaCliente\": ", avnc[viagem.viagem]);
				f.writeln("	},");			
			}		
		}
	}
	f.writeln("]");
	f.writeln("}");	
	f.close();
}



