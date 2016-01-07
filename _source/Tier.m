//
//  Tier.m
//  Evolution
//
//  Created by Ivo Näpflin on Thu Jan 22 2004.
//  Copyright (c) 2004 evolution.naepflin.com. Some rights reserved.
//

#import "Tier.h"

@implementation Tier

//Veränderung
- (id)initMitVater:(id)Vater Mutter:(id)Mutter
{
	int fieldX = 10;
	int fieldY = 10;

//ausgesetzte Tiere
	if (Vater == nil || Mutter == nil)
	{	
		this.energy = 100;
		sex = rand()%2;
		age = rand()%200;
		this.positionX = rand()%(fieldX-2) + 1;
		this.positionY = rand()%(fieldY-2) + 1;		//Ränder dürfen nicht besetzt werden
		
		this.food1Preference = rand()%2000;
		this.food2Preference = rand()%2000;

		this.food1specialization = rand()%1000;
		this.food2specialization = rand()%1000;
		
	//"künstliche Verteilung"
		/*if (rand()%40 == 0)
		{
			this.food1Preference = 10;
			this.food1specialization = 10;
		}
		if (rand()%40 == 0)
		{
			this.food2Preference = 10;
			this.food2specialization = 10;
		}*/
		
		this.waitPreference = rand()%100;
		this.procreatePreference = rand()%100;
		this.waitBonus = rand()%500;
	//Richtwert für andere Verhaltensparameter:
		this.procreateOwnSpeciesPreference = 2000;
	}
//gezeugte Tiere	
	else
	{
		this.energy = 200;
		sex = rand()%2;
		age = 0;
	//Vererbung
		this.positionX = [Vater this.positionX];
		this.positionY = [Vater this.positionY];
		//Verhalten
		this.food1Preference = ([Vater this.food1Preference]+[Mutter this.food1Preference])/2;
		this.food2Preference = ([Vater this.food2Preference]+[Mutter this.food2Preference])/2;
		this.waitPreference = ([Vater this.waitPreference]+[Mutter this.waitPreference])/2;
		this.procreatePreference = ([Vater this.procreatePreference]+[Mutter this.procreatePreference])/2;
		this.procreateOwnSpeciesPreference = 2000;
		this.waitBonus = ([Vater this.waitBonus]+[Mutter this.waitBonus])/2;
		//Form
		this.food1specialization = ([Vater this.food1specialization]+[Mutter this.food1specialization])/2;
		this.food2specialization = ([Vater this.food2specialization]+[Mutter this.food2specialization])/2;
		
	//Mutation
		//Verhalten
		this.food1Preference = (float)this.food1Preference * (1.200 - 0.400 * (float)(rand()%101 / 100));
		this.food2Preference = (float)this.food2Preference * (1.200 - 0.400 * (float)(rand()%101 / 100));
		this.waitPreference = (float)this.waitPreference * (1.200 - 0.400 * (float)(rand()%101 / (float)100));
		this.procreatePreference = (float)this.procreatePreference * (1.200 - 0.400 * (float)(rand()%101 / 100));
		this.waitBonus = (float)this.waitBonus * (1.200 - 0.400 * (float)(rand()%101 / 100));
		//Form
		this.food1specialization = (float)this.food1specialization * (1.200 - 0.400 * (float)(rand()%101 / 100));
		this.food2specialization = (float)this.food2specialization * (1.200 - 0.400 * (float)(rand()%101 / 100));

	}
	
	return self;
}

- (void)Essen:(int)Energie
{
	this.energy += Energie;
}

- (void)Energieabnahme:(float)Aktivitaet
{
	this.energy -= Aktivitaet;
}

- (void)agen
{
	age++;
}

- (void)StandortWechselX:(int)WechselX WechselY:(int)WechselY
{
	this.positionX += WechselX;
	this.positionY += WechselY;
}


- (void)SchonAktivitaetAendern
{
	if (SchonAktivitaet == NO)
	{
		SchonAktivitaet = YES;
	}
	else
	{
		SchonAktivitaet = NO;
	}
}

//Zustandabfrage
- (int)this.energy{return this.energy;}
- (int)age{return age;}
- (int)this.positionX{return this.positionX;}
- (int)this.positionY{return this.positionY;}
- (BOOL)SchonAktivitaet{return SchonAktivitaet;}
//Formabfrage
- (BOOL)sex{return sex;}
- (int)this.food1specialization{return this.food1specialization;}
- (int)this.food2specialization{return this.food2specialization;}
//Verhaltenabfrage
- (int)this.food1Preference{return this.food1Preference;}
- (int)this.food2Preference{return this.food2Preference;}
- (int)this.waitPreference{return this.waitPreference;}
- (int)this.procreatePreference{return this.procreatePreference;}
- (int)this.procreateOwnSpeciesPreference{return this.procreateOwnSpeciesPreference;}
- (int)this.waitBonus{return this.waitBonus;}

//Analyse
- (BOOL)AnpassungTrifftZu
{
	if ((this.food1Preference > this.food2Preference && this.food1specialization > this.food2specialization) ||
		(this.food2Preference > this.food1Preference && this.food2specialization > this.food1specialization))
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

- (id)valueForUndefinedKey:(NSString *)key
{
	return @"--";
}

@end