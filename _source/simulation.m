//
//  Simulation.m
//  Evolution
//
//  Created by Ivo Näpflin.
//  Copyright (c) 2004 evolution.naepflin.com. Some rights reserved.
//

#import "Simulation.h"
#import "Controller.h"
#import "Tier.h"
#import "Feld.h"

@implementation Simulation

NSMutableArray *Tiere; 
NSMutableArray *Felder; 
BOOL prozessLauf;
int AnzahlFelderX;
int AnzahlFelderY;
int Rand;
int r, s, t, u, v, w, i, z;
int ProzessZaehler;

//Steuerung
- (id)init
{
	Tiere = [[NSMutableArray alloc] init];
	Felder = [[NSMutableArray alloc] init];
	int ProzessZaehler = 0;
			
// Felder erstellen
	AnzahlFelderX = 10;	//Feldgrösse X
	AnzahlFelderY = 10;	//Feldgrösse Y
	AnzahlFelderX--;
	AnzahlFelderY--;
	

	for (r = 0; r <= AnzahlFelderX; r++)
	{
		NSMutableArray *Reihe = [[NSMutableArray alloc] init];
		for (s = 0; s <= AnzahlFelderY; s++)
			{
				if (r == 0 || r == AnzahlFelderX || s == 0 || s == AnzahlFelderY)
				{
					[Reihe addObject:[[Feld alloc] initAmRand:YES]];
				}
				else
				{
					[Reihe addObject:[[Feld alloc] initAmRand:NO]];
				}
			}
		[Felder addObject:Reihe];
		[Reihe release];
	}
	
//für zufällige Zufallswerte nötig:
	srand([[NSDate date] timeIntervalSince1970]);
	rand(); rand(); rand();
	
	return self;
} 

- (id)starten:(id)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	prozessLauf = YES;
		
//Prozess wird gestartet
	while (prozessLauf)
	{
	//Alle Tiere werden bewegt
		for (z = 0; z < [Tiere count]; z++)
		{
			[self ZugController:z];
		//Hier wäre eine geeignete Stelle, um Populationsstatistiken einzubauen.
		}
		
	//Alle Felder wachsen
		for (t = 0; t < AnzahlFelderX; t++)
		{
			NSMutableArray *Reihe;
			Reihe = [Felder objectAtIndex:t];

			for (u = 0; u < AnzahlFelderY; u++)
				{
					[[Reihe objectAtIndex:u] Wachsen];
				}
		}

	//Wenn nur noch [stoppenBei intValue] Tiere da sind: stoppen, um auszuwerten. [stoppenBei intValue] = 0 für aussterben lassen.
		if ([Tiere count] < [stoppenBei intValue])
		{
			NSBeep();
			[myController Stop:self];
		}

//Wenn keine Tiere mehr da sind: stoppen, um Endlosschleife (Leerlauf) zu vermeiden
		if ([Tiere count] < 1)
		{
			NSBeep();
			[myController Stop:self];
		}
	
		ProzessZaehler++;

	}
	
	[pool release];
	
	return self;
}

- (id)stoppen:(id)sender
{
	prozessLauf = NO;
	return self;
}

- (void)TiereAussetzenSim:(int)Anzahl
{
	int v;
	for (v = 0; v < Anzahl; v++)
	{
		[Tiere addObject:[[Tier alloc] initMitVater:nil Mutter:nil]];
	}
}

- (id)RundenZaehlerReset:(id)sender
{
	ProzessZaehler = 0;
	[myController Anzeigen:self];
	return self;
}

- (id)alleTiereSterben:(id)sender
{
	int AnzahlTiere = [Tiere count];
	for (v = 0; v < AnzahlTiere; v++)
	{
		[self TierStirbt:[Tiere objectAtIndex:0]];
	}
	[myController Anzeigen:self];
	return self;
}


//Prozess
- (id)ZugController:(int)TierID
{
	id gewaehltesTier = [Tiere objectAtIndex:TierID];
	int StandortX = [gewaehltesTier StandortX];
	int StandortY = [gewaehltesTier StandortY];
	
	[gewaehltesTier Altern];
//Energie für Leben
	[gewaehltesTier Energieabnahme:(float)[gewaehltesTier Nahrung1Anpassung]*[Anpassung1Energieverlust floatValue]]; //soll etwa 20 geben
	[gewaehltesTier Energieabnahme:(float)[gewaehltesTier Nahrung2Anpassung]*[Anpassung2Energieverlust floatValue]]; //soll etwa 20 geben

// Im Alter von 200 Runden oder mit negativer Energie stirbt ein Tier:
	if([gewaehltesTier Energiestand] < 0 || [gewaehltesTier Alter] > 200)
	{
		[self TierStirbt:[Tiere objectAtIndex:TierID]];
	}
	else
	{
	//Entscheidungsprozess wird eingeleitet
		[self EntscheidungTier:gewaehltesTier];
	}
	
	return self;
}

//Abfrage
- (int)AnzahlTiere{return [Tiere count];}
- (id)TierMitID:(int)ID{return [Tiere objectAtIndex:ID];}
- (int)ProzessZaehler{return ProzessZaehler;}


//Prozesshilfe
- (id)EntscheidungTier:(id)gewaehltesTier
{
	int StandortX = [gewaehltesTier StandortX];
	int StandortY = [gewaehltesTier StandortY];
	
	int TierID = [Tiere indexOfObjectIdenticalTo:gewaehltesTier];

	id zweitesTier = nil;
	
	int PunkteFuerTatUndZug[3][9];
			//0 = Fortpflanzung
			//1 = Essen
			//2 = Warten
			
	id moeglichesFeld[9];
	int Gesamtpunktzahl = 0;
	
	moeglichesFeld[0] = [[Felder objectAtIndex:StandortX-1] objectAtIndex:StandortY-1];
	moeglichesFeld[1] = [[Felder objectAtIndex:StandortX-1] objectAtIndex:StandortY+0];
	moeglichesFeld[2] = [[Felder objectAtIndex:StandortX-1] objectAtIndex:StandortY+1];
	moeglichesFeld[3] = [[Felder objectAtIndex:StandortX+0] objectAtIndex:StandortY-1];
	moeglichesFeld[4] = [[Felder objectAtIndex:StandortX+0] objectAtIndex:StandortY+0];
	moeglichesFeld[5] = [[Felder objectAtIndex:StandortX+0] objectAtIndex:StandortY+1];
	moeglichesFeld[6] = [[Felder objectAtIndex:StandortX+1] objectAtIndex:StandortY-1];
	moeglichesFeld[7] = [[Felder objectAtIndex:StandortX+1] objectAtIndex:StandortY+0];
	moeglichesFeld[8] = [[Felder objectAtIndex:StandortX+1] objectAtIndex:StandortY+1];

//Attraktivität der verschiedenen Felder ermitteln
    int Nahrung1Parameter = [gewaehltesTier Nahrung1Parameter];
    int Nahrung2Parameter = [gewaehltesTier Nahrung2Parameter];
    int WartenParameter = [gewaehltesTier WartenParameter];
    int FortpflanzungParameter = [gewaehltesTier FortpflanzungParameter];
    int FortpflanzungEigeneArtParameter = [gewaehltesTier FortpflanzungEigeneArtParameter];
	int StehenBleibenBonus = [gewaehltesTier StehenBleibenBonus];
	for (v = 0; v < 9; v++)
	{
		zweitesTier = [moeglichesFeld[v] getTier];
		if (zweitesTier != nil && zweitesTier != gewaehltesTier && [zweitesTier Geschlecht] != [gewaehltesTier Geschlecht])
		{
	//Fortpflanzung
		//wenn eigene Art
			if (([gewaehltesTier Nahrung2Anpassung] > [zweitesTier Nahrung2Anpassung]*0.600 && [gewaehltesTier Nahrung2Anpassung]*0.600 < [zweitesTier Nahrung2Anpassung]) && ([gewaehltesTier Nahrung1Anpassung] > [zweitesTier Nahrung1Anpassung]*0.600 && [gewaehltesTier Nahrung1Anpassung]*0.600 < [zweitesTier Nahrung1Anpassung]))
			{
				PunkteFuerTatUndZug[0][v] = FortpflanzungEigeneArtParameter;
			}
		//wenn andere Art
			else
			{
				PunkteFuerTatUndZug[0][v] = FortpflanzungParameter;
			}
		}
		else
		{
			PunkteFuerTatUndZug[0][v] = 0;
		}
		
	//Essen
		//Wenn Nahrung1
		if([moeglichesFeld[v] Art] == 1)
		{
			PunkteFuerTatUndZug[1][v] = [moeglichesFeld[v] Beweidung] / 100 * Nahrung1Parameter;
		}
		//Wenn Nahrung2
		if([moeglichesFeld[v] Art] == 2)
		{
			PunkteFuerTatUndZug[1][v] = [moeglichesFeld[v] Beweidung] / 100 * Nahrung2Parameter;
		}
		//Wenn Feld am Rand
		if([moeglichesFeld[v] Art] == 3)
		{
			PunkteFuerTatUndZug[1][v] = 0;
		}
		
	//Warten
		PunkteFuerTatUndZug[2][v] = WartenParameter;		
	}
	
//Bonus für Stehenbleiben verteilen
	for (v = 0; v < 4; v++)
	{
		PunkteFuerTatUndZug[v][4] = PunkteFuerTatUndZug[v][4] + StehenBleibenBonus;
	}
	
//Gesamtpunktzahl berechnen
	for (v = 0; v < 9; v++)
	{
		for (w = 0; w < 3; w++)
		{
			Gesamtpunktzahl = Gesamtpunktzahl + PunkteFuerTatUndZug[w][v];
		}
	}

//Wahl treffen
	if (Gesamtpunktzahl > 0)
	{
		Rand = rand()%Gesamtpunktzahl;
		int bisherigePunkte = 0;
		int GesamtpunkteFuerZug[9];
		
	//Gesamtpunktzahlen für die einzelnen Züge (ohne Taten) berechnen
		for (v = 0; v < 9 ; v++)
		{
			GesamtpunkteFuerZug[v] = PunkteFuerTatUndZug[0][v] + PunkteFuerTatUndZug[1][v] + PunkteFuerTatUndZug[2][v];
		}
		
	//Wahl zufällig ermitteln
		int TatID = 2;

		if (Rand < GesamtpunkteFuerZug[0])
		{
			Rand = rand()%GesamtpunkteFuerZug[0];
			
			if (Rand < PunkteFuerTatUndZug[0][0])
			{
				TatID = 0;
			}
			else
			{
				if (Rand < PunkteFuerTatUndZug[1][0] + PunkteFuerTatUndZug[0][0])
				{
					TatID = 1;
				}
			}
			
			[self Tier:gewaehltesTier willTun:TatID mitBewegungUmX:-1 UmY:-1];
			return self;
		}
		bisherigePunkte += GesamtpunkteFuerZug[0];
		
		if (Rand < (bisherigePunkte + GesamtpunkteFuerZug[1]))
		{
			Rand = rand()%GesamtpunkteFuerZug[1];

			if (Rand < PunkteFuerTatUndZug[0][1])
			{
				TatID = 0;
			}
			else
			{
				if (Rand < PunkteFuerTatUndZug[1][1] + PunkteFuerTatUndZug[0][1])
				{
					TatID = 1;
				}
			}
			
			[self Tier:gewaehltesTier willTun:TatID mitBewegungUmX:-1 UmY:0];
			
			return self;
		}
		bisherigePunkte += GesamtpunkteFuerZug[1];
		
		if (Rand < (bisherigePunkte + GesamtpunkteFuerZug[2]))
		{
			Rand = rand()%GesamtpunkteFuerZug[2];

			if (Rand < PunkteFuerTatUndZug[0][2])
			{
				TatID = 0;
			}
			else
			{
				if (Rand < PunkteFuerTatUndZug[1][2] + PunkteFuerTatUndZug[0][2])
				{
					TatID = 1;
				}
			}
			
			[self Tier:gewaehltesTier willTun:TatID mitBewegungUmX:-1 UmY:1];
			
			return self;
		}
		bisherigePunkte += GesamtpunkteFuerZug[2];
		
		if (Rand < (bisherigePunkte + GesamtpunkteFuerZug[3]))
		{
			Rand = rand()%GesamtpunkteFuerZug[3];

			if (Rand < PunkteFuerTatUndZug[0][3])
			{
				TatID = 0;
			}
			else
			{
				if (Rand < PunkteFuerTatUndZug[1][3] + PunkteFuerTatUndZug[0][3])
				{
					TatID = 1;
				}
			}
			
			[self Tier:gewaehltesTier willTun:TatID mitBewegungUmX:0 UmY:-1];
			
			return self;
		}
		bisherigePunkte += GesamtpunkteFuerZug[3];
		
		if (Rand < (bisherigePunkte + GesamtpunkteFuerZug[4]))
		{
			Rand = rand()%GesamtpunkteFuerZug[4];

			if (Rand < PunkteFuerTatUndZug[0][4])
			{
				TatID = 0;
			}
			else
			{
				if (Rand < PunkteFuerTatUndZug[1][4] + PunkteFuerTatUndZug[0][4])
				{
					TatID = 1;
				}
			}
			
			[self Tier:gewaehltesTier willTun:TatID mitBewegungUmX:0 UmY:0];
			
			return self;
		}
		bisherigePunkte += GesamtpunkteFuerZug[4];
		
		if (Rand < (bisherigePunkte + GesamtpunkteFuerZug[5]))
		{
			Rand = rand()%GesamtpunkteFuerZug[5];

			if (Rand < PunkteFuerTatUndZug[0][5])
			{
				TatID = 0;
			}
			else
			{
				if (Rand < PunkteFuerTatUndZug[1][5] + PunkteFuerTatUndZug[0][5])
				{
					TatID = 1;
				}
			}
			
			[self Tier:gewaehltesTier willTun:TatID mitBewegungUmX:0 UmY:1];
			
			return self;
		}
		bisherigePunkte += GesamtpunkteFuerZug[5];
		
		if (Rand < (bisherigePunkte + GesamtpunkteFuerZug[6]))
		{
			Rand = rand()%GesamtpunkteFuerZug[6];

			if (Rand < PunkteFuerTatUndZug[0][6])
			{
				TatID = 0;
			}
			else
			{
				if (Rand < PunkteFuerTatUndZug[1][6] + PunkteFuerTatUndZug[0][6])
				{
					TatID = 1;
				}
			}
			
			[self Tier:gewaehltesTier willTun:TatID mitBewegungUmX:1 UmY:-1];
			
			return self;
		}
		bisherigePunkte += GesamtpunkteFuerZug[6];
		
		if (Rand < (bisherigePunkte + GesamtpunkteFuerZug[7]))
		{
			Rand = rand()%GesamtpunkteFuerZug[7];

			if (Rand < PunkteFuerTatUndZug[0][7])
			{
				TatID = 0;
			}
			else
			{
				if (Rand < PunkteFuerTatUndZug[1][7] + PunkteFuerTatUndZug[0][7])
				{
					TatID = 1;
				}
			}
			
			[self Tier:gewaehltesTier willTun:TatID mitBewegungUmX:1 UmY:0];
			
			return self;
		}
		
		Rand = rand()%GesamtpunkteFuerZug[8];

			if (Rand < PunkteFuerTatUndZug[0][8])
			{
				TatID = 0;
			}
			else
			{
				if (Rand < PunkteFuerTatUndZug[1][8] + PunkteFuerTatUndZug[0][8])
				{
					TatID = 1;
				}
			}
		
		[self Tier:gewaehltesTier willTun:TatID mitBewegungUmX:1 UmY:1];
		
		return self;
	}
	
//Wenn die Gesamtpunktzahl < 1 ist
	else
	{
		[self Tier:gewaehltesTier willTun:2 mitBewegungUmX:0 UmY:0];
	}

	return self;
}

- (id)Tier:(id)gewaehltesTier willTun:(int)TatID mitBewegungUmX:(int)VerschiebungX UmY:(int)VerschiebungY
{
//die verschiedenen TatIDs:
	int Fortpflanzung = 0;
	int Essen = 1;
	int Warten = 2;
	
	int alterStandortX = [gewaehltesTier StandortX];
	int alterStandortY = [gewaehltesTier StandortY];
//neuer Standort bleibt vorerst noch alter, denn vielleicht ist Bewegung ungültig (z.B. auf Randfeld)
	int neuerStandortX = alterStandortX;
	int neuerStandortY = alterStandortY;
	
	id WunschZielFeld = [[Felder objectAtIndex:alterStandortX+VerschiebungX] objectAtIndex:alterStandortY+VerschiebungY];
	
	id zweitesTier = [WunschZielFeld getTier];

//Bewegung
	if ([WunschZielFeld Art] == 3)
	{
	//Wenn WunschZielFeld nicht erreicht werden kann
		[[[Felder objectAtIndex:alterStandortX] objectAtIndex:alterStandortY] neuesTier:gewaehltesTier];
		[gewaehltesTier Energieabnahme:[BewegungEnergieverlust floatValue]];
	}
	else
	{
	//Wenn WunschZielFeld erreicht werden kann
		if (VerschiebungX != 0 && VerschiebungY != 0)
		{
		//Energie für Bewegung
			[gewaehltesTier Energieabnahme:[BewegungEnergieverlust floatValue]];
		//Bewegung ausführen
			[gewaehltesTier StandortWechselX:VerschiebungX WechselY:VerschiebungY];
			neuerStandortX = [gewaehltesTier StandortX];
			neuerStandortY = [gewaehltesTier StandortY];
		}

		id neuesFeld = [[Felder objectAtIndex:neuerStandortX] objectAtIndex:neuerStandortY];
		
	//sich vom alten Feld entfernen
		[[[Felder objectAtIndex:alterStandortX] objectAtIndex:alterStandortY] neuesTier:nil];
	//sich beim neuen Feld registrieren
		[neuesFeld neuesTier:gewaehltesTier];
		
		if ([gewaehltesTier SchonAktivitaet] == YES)
		{
			[gewaehltesTier SchonAktivitaetAendern];
		}
		else
		{
	//Aktivitäten
		//Fortpflanzung
			if (TatID == Fortpflanzung)
			{
				
			//Bedingungen für Fortpflanzung mit anderem Tier
				if (zweitesTier != nil && zweitesTier != gewaehltesTier
					&& /*selbe Art:*/ (([gewaehltesTier Nahrung2Anpassung] > [zweitesTier Nahrung2Anpassung]*0.600 && [gewaehltesTier Nahrung2Anpassung]*0.600 < [zweitesTier Nahrung2Anpassung]) && ([gewaehltesTier Nahrung1Anpassung] > [zweitesTier Nahrung1Anpassung]*0.600 && [gewaehltesTier Nahrung1Anpassung]*0.600 < [zweitesTier Nahrung1Anpassung]))
					&& [zweitesTier SchonAktivitaet] == NO
					&& [zweitesTier Geschlecht] != [gewaehltesTier Geschlecht])
				{
					[gewaehltesTier Energieabnahme:[FPaktivEnergieverlust floatValue]];
					[Tiere addObject:[[Tier alloc] initMitVater:gewaehltesTier Mutter:zweitesTier]];
					[zweitesTier SchonAktivitaetAendern];
					[zweitesTier Energieabnahme:[FPpassivEnergieverlust floatValue]];
				}
			}
		
		//Essen
			if (TatID == Essen)
			{
				[gewaehltesTier Energieabnahme:[EssenEnergieverlust floatValue]];
				
				if ([neuesFeld Nutzung] == YES)
				{
					if ([neuesFeld Art] == 1)
					{
						[gewaehltesTier Essen:(float)[gewaehltesTier Nahrung1Anpassung]/5]; //soll etwa 100 geben
					}
					if ([neuesFeld Art] == 2)
					{
						[gewaehltesTier Essen:(float)[gewaehltesTier Nahrung2Anpassung]/5]; //soll etwa 100 geben
					}
				}
			}
		//Warten geschieht, wenn nicht Essen oder Fortpflanzung
		}
	}

	return self;
}
- (id)TierStirbt:(id)TierID
{
	id myFeld = [[Felder objectAtIndex:[TierID StandortX]] objectAtIndex:[TierID StandortY]];
	[myFeld neuesTier:nil];
	[Tiere removeObjectAtIndex:[Tiere indexOfObjectIdenticalTo:TierID]];
	return self;
}

@end
