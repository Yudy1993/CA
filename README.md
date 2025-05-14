# Copyright agent case
## Overall
Super spændende og udfordrende case med gode spørgsmål! 
## Guide
- data: Filerne der er blevet givet i casen 
- models: Modellerne jeg har generet 
- visuals: Grafer baseret på data og modeller
## Process
For at kunne løse den her opgave har jeg sat en PostgresSQL server up lokalt. Derefter queried jeg modellerne i pgAdmin og sat en forbindelse op mod powerBI hvor jeg kunne skabe graferne udfra modellerne mv. Har aldrig arbejde med PostgresSQL dialect før så der var mega spændende at prøve data modellering af. 
## Analysis Objectives(noter)
### Case insights
- Case Resolution Time: Samlede vundet og tabte sager via en CTE og udregnet tiden fra hvornår en sag var "open" og trak tiden fra hvornår den enten var "tabt" eller "vundet". Splittet tiden derefter i dage og timer.
- Maximum case cost: Den her har jeg nok ramt forkert kunne ikke helt forstå hvad det skulle koste for at køre en sag baseret på dataen, så antog at det var i forbindelse med break-even på hvor meget case-value der var på sager der var vundet. Tog sum af vundet og tabte sager, talte hvor mange åbne sager der var og udregnet hvad de nuværender åbene sager måtte have a case_value gennemsnitligt.
### Client insights
- Client Lifetime Value (CLTV) Segmentation: Delte clienter op med deres totale vundne sager og udregnede en median ved at tage en procentandel for at kunne splitte dem i 3. Derefter defineret hvad de skulle navngives som.
- Predictive Client Value: Prøvede i første omgang med monthly_prediction at bruge historiske gennemsnit og gange det for at få en forecast, men der var for lidt data til det rigtig gave så meget værdi. Derefter forsøgte jeg med en med en mere data drevet approach, hvor jeg tog den måndelig værdi og brugte win rates og case value for at få nogle fordelingsvægte at gå ud fra. 
### Market insights
- Market trends: Her lavede jeg en simple chart som du kan se i graferne hvor jeg udregnede nogle rates til sammenligning. Mangler en tidsdimension og måske en linje chart men der var bare ikke rigtig nok data til at jeg synes det ville se særlig godt ud. 
