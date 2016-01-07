//
//  Feld.m
//  Evolution
//
//  Created by Ivo Näpflin on Tue Apr 13 2004.
//  Copyright (c) 2004 evolution.naepflin.com. Some rights reserved.
//

#import "Feld.h"


@implementation Feld

//Veränderung
- (id)initAmRand:(BOOL)AmRand
{
	if (AmRand)
	{
		Art = 3;
	}
	else
	{
		Art = rand()%2 + 1;
	}
	
	Beweidung = 1000;
		
	TierID = nil;
	
	return self;
}

- (BOOL)Nutzung
{
	if (Beweidung > 0)
	{
		Beweidung -= 100;
		return YES;
	}
	else
	{
		return NO;
	}
}

- (void)Wachsen
{
	float Wachstum = 500;

	Beweidung += Wachstum;
	return;
}

- (void)neuesTier:(id)ID
{
	TierID = ID;
	return;
}

//Abfrage
- (int)Beweidung{return Beweidung;}
- (id)getTier{return TierID;}
- (int)Art{return Art;}

@end
