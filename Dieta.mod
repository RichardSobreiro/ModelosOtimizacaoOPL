int qConcreto = ...; // Quantidade de tipos de concreto 
int qPeriodo = ...; // Quantidade de dias de planejamento
int qPontosCarga = ...; // Quantidade de pontos de carga
int qCimento = ...; // Quantidade de cimentos
int qAdicao = ...; // Quantidade de adições
int qAgregadoMiudo = ...; // Quantidade de agregados miudos
int qAgregadoGraudo = ...; // Quantidade de agregaados graudos
int qAgua = ...; // Quantidade de água
int qAditivo = ...; // Quantidade de aditivos
int qMateriaisAdicionais = ...; // Quantidade de materiais adicionais

// Conjuntos
range C = 1..qConcreto;
range CT = 1..qCimento;
range AD = 1..qAdicao;
range AM = 1..qAgregadoMiudo;
range AG = 1..qAgregadoGraudo;
range A = 1..qAgua;
range AV = 1..qAditivo;
range MA = 1..qMateriaisAdicionais;
range T = 1..qPeriodo;
range P = 1..qPontosCarga;

// Parametros
float d[C][T] = ...; // Demanda do concreto c no dia t

float QP[P][T] = ...;

float qct[CT][C] = ...; // Quantidade do cimento ct necessária para produzir um metro cúbico do concreto c
float qad[AD][C] = ...; // Quantidade da adição ad necessária para produzir um metro cúbico do concreto c
float qam[AM][C] = ...; // Quantidade da areia am necessária para produzir um metro cúbico do concreto c 
float qag[AG][C] = ...; // Quantidade da brita ag necessária para produzir um metro cúbico do concreto c
float qa[A][C] = ...;  // Quantidade da água a necessária para produzir um metro cúbico do concreto c
float qav[AV][C] = ...; // Quantidade do aditivo av necessário para produzir um metro cúbico do concreto c
float qma[MA][C] = ...; // Quantidade do material adicional ma necessário para produzir um metro cúbico do concreto c

float cct[CT][P][T] = ...; // Custo do metro cúbico do cimento ct no ponto de carga p
float cad[AD][P][T] = ...; // Custo unitário da adição ad no ponto de carga p
float cam[AM][P][T] = ...; // Custo unitário da areia am no ponto de carga p 
float cag[AG][P][T] = ...; // Custo unitário da brita ag no ponto de carga p
float ca[A][P][T] = ...;  // Custo unitário da água a no ponto de carga p
float cav[AV][P][T] = ...; // Custo unitário do aditivo av no ponto de carga p
float cma[MA][P][T] = ...; // Custo unitário do material adicional ma no ponto de carga p 

float ecto[CT][P] = ...; // Estoque inicial do cimento c
float eado[AD][P] = ...; // Estoque inicial de adição ad no ponto de carga p
float eamo[AM][P] = ...; // Estoque inicial de areia am no ponto de carga p
float eago[AG][P] = ...; // Estoque inicial de brita ag no ponto de carga p
float eao[A][P] = ...; // Estoque inicial de água a no ponto de carga p
float eavo[AV][P] = ...; // Estoque inicial de aditivo av no ponto de carga p
float emao[MA][P] = ...; // Estoque inicial de material adicional ma no ponto de carga p

float Mc[C][P][T] = ...; // Máxima quantidade de concreto c que pode ser demandada no ponto de carga p no dia t

// Variáveis
dvar float xct[CT][P][T]; // Quantidade de cimento ct a ser comprada no ponto de carga p no dia t
dvar float xad[AD][P][T]; // Quantidade de adição ad a ser comprada no ponto de carga p no dia t
dvar float xam[AM][P][T]; // Quantidade de areia am a ser comprada no ponto de carga p no dia t
dvar float xag[AG][P][T]; // Quantidade de brita ag a ser comprada no ponto de carga p no dia t
dvar float xa[A][P][T]; // Quantidade de água a a ser comprada no ponto de carga p no dia t
dvar float xav[AV][P][T]; // Quantidade de aditivo av a ser comprada no ponto de carga p no dia t
dvar float xma[MA][P][T]; // Quantidade de material adicional ma a ser comprada no ponto de carga p no dia t
 
dvar float ect[CT][P][T]; // Estoque do cimento c no dia t
dvar float ead[AD][P][T]; // Estoque de adição ad no ponto de carga p no dia t
dvar float eam[AM][P][T]; // Estoque de areia am no ponto de carga p no dia t
dvar float eag[AG][P][T]; // Estoque de brita ag no ponto de carga p no dia t
dvar float ea[A][P][T]; // Estoque de água a no ponto de carga p no dia t
dvar float eav[AV][P][T]; // Estoque de aditivo av no ponto de carga p no dia t
dvar float ema[MA][P][T]; // Estoque de material adicional ma no ponto de carga p no dia t

dvar float cc[C][P][T]; // Custo do metro cúbico do concreto ct no ponto de carga p no dia t
dvar float xc[C][P][T]; // Quantidade de concreto c produzida no ponto de carga p no dia t
//dvar boolean y[C][P][T]; // Se o concreto c será produzido no ponto de carga p no dia t

// Modelo
minimize sum(c in C, p in P, t in T)(cc[c][p][t]);

subject to {
	ControleEstoqueDeCimento:
	forall(ct in CT, p in P, t in T, c in C){
		if(t > 1){
			ect[ct][p][t] >= ect[ct][p][t-1] + xct[ct][p][t] - (qct[ct][c] * xc[c][p][t]);
		}
		else{
			ect[ct][p][t] == ecto[ct][p];
		}
	}
	ControleEstoqueDeAdicao:
	forall(ad in AD, p in P, t in T, c in C: t > 1){
		ead[ad][p][t] >= ead[ad][p][t-1] + xad[ad][p][t] - (qad[ad][c] * xc[c][p][t]);
	}
	forall(ad in AD, p in P, c in C){
		ead[ad][p][1] == eado[ad][p];
	}
	ControleEstoqueAgregadoMiudo:
	forall(am in AM, p in P, t in T, c in C){
		if(t > 1){
			eam[am][p][t] >= eam[am][p][t-1] + xam[am][p][t] - (qam[am][c] * xc[c][p][t]);
		}
		else{
			eam[am][p][t] == eamo[am][p];
		}
	}
	ControleEstoqueDeAgregadoGraudo:
	forall(ag in AG, p in P, t in T, c in C){
		if(t > 1){
			eag[ag][p][t] >= eag[ag][p][t-1] + xag[ag][p][t] - (qag[ag][c] * xc[c][p][t]);
		}
		else{
			eag[ag][p][t] == eago[ag][p];
		}
	}
	ControleEstoqueDeAgua:
	forall(a in A, p in P, t in T, c in C){
		if(t > 1){
			ea[a][p][t] >= ea[a][p][t-1] + xa[a][p][t] - (qa[a][c] * xc[c][p][t]);
		}
		else{
			ea[a][p][t] == eao[a][p];
		}
	}
	ControleEstoqueDeAditivo:
	forall(av in AV, p in P, t in T, c in C){
		if(t > 1) {
			eav[av][p][t] >= eav[av][p][t-1] + xav[av][p][t] - (qav[av][c] * xc[c][p][t]);
		}
		else {
			eav[av][p][t] == eavo[av][p];
		}
	}
	ControleEstoqueDeMaterialAdicional:
	forall(ma in MA, p in P, t in T, c in C){
		if(t > 1) {
			ema[ma][p][t] >= ema[ma][p][t-1] + xma[ma][p][t] - (qma[ma][c] * xc[c][p][t]);
		}
		else {
			ema[ma][p][t] == emao[ma][p];
		}
	}
	
	/*DisponibilidadeDoConcretoNoPontoCargaNoDia:
	forall(c in C, p in P, t in T){
		xc[c][p][t] <= Mc[c][p][t] * y[c][p][t];   
	}*/
	
	DemandaDoConcreto:
	forall(c in C, t in T){
		sum( p in P )(xc[c][p][t]) >= d[c][t]; 	
	}
	
	CustoDoConcreto:
	forall(c in C, p in P, t in T, ct in CT, ad in AD, am in AM, ag in AG, a in A, av in AV, ma in MA) {
		cc[c][p][t] >= 
			(qct[ct][c] * xc[c][p][t] * cct[ct][p][t]) + 
			(qad[ad][c] * xc[c][p][t] * cad[ad][p][t]) + 
			(qam[am][c] * xc[c][p][t] * cam[am][p][t]) + 
			(qag[ag][c] * xc[c][p][t] * cag[ag][p][t]) + 
			(qa[a][c] * xc[c][p][t] * ca[a][p][t]) + 
			(qav[av][c] * xc[c][p][t] * cav[av][p][t]) + 
			(qma[ma][c] * xc[c][p][t] * cma[ma][p][t]);	
	}
	
	CapacidadePontosCarga:
	forall(p in P, t in T){
		sum(c in C)(xc[c][p][t]) <= QP[p][t];
	}
	
	NaoNegatividadeDasVariaveis:
	forall(c in C, p in P, t in T) {
		xc[c][p][t] >= 0;
		cc[c][p][t] >= 0;
	}
}

execute {
	var qtdTotalProduzida = 0;
	for(var t in T){
		for(var c in C ) {
			qtdTotalProduzida = 0;
			for(var p in P){
				qtdTotalProduzida += xc[c][p][t];
			}
			writeln("--------------------------------------------------------------");
			writeln("CONCRETO: ",c," | DIA: ",t," => ");
			writeln("Demanda: ",d[c][t]," | QtdTotalProduzida de ",c," : ",qtdTotalProduzida);
			for(var p in P){
				writeln("Qtd Produzida Ponto Carga ",p," : ", xc[c][p][t]);
				writeln("Custo produção Ponto Carga ",p," : ", cc[c][p][t]);
			}
			writeln("--------------------------------------------------------------");
		}		
	}
}