# Izveštaj analize projekta VPaint

## Clang alati

### Clang-Tidy

Clang-Tidy je alat za statičku analizu koda u okviru Clang kompajlera projekta LLVM. Ovaj alat se primenjuje za pronalaženje stilskih grešaka i bagova koji mogu da se uoče bez izvršavanja izvornog koda.

Clang-Tidy je integrisan u okviru razvojnog okruženja QtCreator, pa se analiza može pokrenuti tako što se iz padajućeg menija Analyze izabere opcija Clang-Tidy and Clazy, a zatim se biraju fajlovi koje želimo da analiziramo.

![file select](clang/analyze-files.png)

Klikom na dugme Analyze pokreće se analiza nad odabranim fajlovima (u ovom slučaju analiziraju se svi fajlovi).

Dobijamo rezultat analize oba alata Clang-Tidy i Clazy. Ukoliko želimo da vidimo samo rezultate analize alatom Clang-Tidy, možemo da primenimo filter:

![results](clang/default-results.png)

Izabrati provere bez prefiksa `clazy`:

![filter](clang/filter.png)

Rezultat Clang-Tidy analize sa predefinisanim podešavanjem:

![clang-tidy default](clang/clang-tidy/clang-tidy-default.png)

Neki od dobijenih upozorenja su vezani za potencijalno curenje memorije, korišćenje već oslobođene memorije, pozivanje virtuelnih metoda, inicijalizovanje vrednosti koje se dalje u kodu ne koriste, korišćenje vrednosti u pokretnom zarezu kao brojače petlji.

Jedno zanimljivo upozorenje je `clang-analyzer-unix.MismatchedDeallocator` sa porukom da se koristi pogrešan operator za dealokaciju (`delete` umesto `free`). 

https://github.com/dalboris/vpaint/blob/58593fe8050376fad7195603c03f8d8851fa775d/src/VAC/VectorAnimationComplex/SculptCurve.h#L187-L205

Međutim, za sve potklase klase Fitter važi da je definisan makro EIGEN_MAKE_ALIGNED_OPERATOR_NEW spoljašnje biblioteke Eigen koji definiše operator delete tako da se njime poziva funkcija free. 

https://github.com/eigenteam/eigen-git-mirror/blob/36b95962756c1fce8e29b1f8bc45967f30773c00/Eigen/src/Core/util/Memory.h#L788-L812

Clang-Tidy ne analizira spoljašnje biblioteke i zato prijavljuje **lažno upozorenje** jer ne može da zna da je predefinisan operator delete.

### Clazy

Clazy je takođe alat za statičku analizu u okviru kompajlera clang, ali namenjen specifično za analizu Qt semantike.

Clazy pokrećemo isto kao i Clang-Tidy, samo što ovog puta biramo upozorenja sa prefiksom clazy u filteru ukoliko želimo da vidimo isključivo upozorenja vezana za Clazy.

![](clang/clazy/clazy-default.png)

Najviše upozorenja vezano je za korišćenje `QHash` umesto `QMap` kad je potrebno da ključ mape bude pokazivač. Drugo najčešće upozorenje vezano je za definisanje signala po [novoj sintaksi](https://wiki.qt.io/New_Signal_Slot_Syntax) umesto po staroj. Primer u klasi `SvgImportDialog.cpp`:

```c++
connect(buttonBox, SIGNAL(accepted()), this, SLOT(accept()));
```

potrebno je zameniti sa:

```c++
connect(buttonBox, &QDialogButtonBox::accepted, this, &SvgImportDialog::accept);
```

Upozorenje fully-qualified-moc-types označava da je potrebno navesti puna kvalifikovana imena tipova u deklaraciji signala/slotova. Clazy navodi preporuku kako bi trebalo izmeniti deklaraciju. Na primer, sledeće slotove:

```c++
void cut(VAC* & clipboard);
void copy(VAC* & clipboard);
void paste(VAC* & clipboard);
```

je potrebno zameniti sa:

```c++
void cut(VectorAnimationComplex::VAC* & clipboard);
void copy(VectorAnimationComplex::VAC* & clipboard);
void paste(VectorAnimationComplex::VAC* & clipboard);
```

### Zaključak

Oba Clang alata su se pokazala korisnim. Clang-Tidy analizom je pronađeno potencijalno curenje memorije, mrtav kod i neke druga upozorenja vezana za sintaksu i performanse koda. Upozorenja dobijena Clazy alatom mogu da skrenu pažnju na korišćenje novije sintakse i na neke dobre prakse prilikom rada u u Qt razvojnom okruženju. Naravno, kao što je viđeno u primeru upozorenja za korišćenje pogrešnog dealokatora, potrebno je razumeti kod, prepoznati lažna upozorenja i znati koje ispravke je moguće primeniti.


## Cppcheck

Cppcheck je alat za statičku analizu koda koji služi za detekciju bagova. 

Cppcheck se može instalirati pokretanjem sledeće komande u terminalu

```bash
sudo apt install cppcheck
```

Nakon instalacije, pozicioniranjem u direktorijum `cppcheck` pokrenuti komandu kojom se projekat analizira alatom:

```
cppcheck --enable=all -isrc/Third --suppressions-list=suppressions.txt --output-file=cppcheck_txt_report.txt ../vpaint
```

Objašnjenje dodatnih opcija:
- `--enable=all` - označava da su sve provere uključene
- `-isrc/Third` - direktorijum na lokaciji `src/Third` je isključen iz analize u kome se nalaze sve spoljašnje biblioteke koje se koriste u projektu. Cilj analize alatom Cppcheck je pronađe bagove u trenutnom projektu (VPaint), a ne u spoljašnjim bibliotekama.
- `--suppressions-list=suppressions.txt` - putanja do fajla u kome su navedene sve provere koje će se ignorisati prilikom analize. U ovom slučaju, provere koje su izostavljene su *missingInclude* i *information*. 
- `--output-file=cppccheck_txt_report.txt` - putanja do fajla u kome će biti upisan rezultat analize

Komanda se može pokrenuti i skriptom [`cppcheck.sh`](cppcheck/cppcheck.sh). Rezultat analize se može videti u fajlu [`cppcheck_txt_report.txt`](cppcheck/cppcheck_txt_report.txt), međutim ukoliko želimo čitljiviji rezultat, Cppcheck omogućava generisanje *html* izveštaja. Najpre je potrebno izveštaj sačuvati u *xml* formatu:

```
cppcheck --enable=all -isrc/Third --suppressions-list=suppressions.txt --output-file=cppcheck_xml_report.xml --xml ../vpaint
```

HTML izveštaj se onda generiše i čuva u direktoriijumu `report` na sledeći način:

```
cppcheck-htmlreport --file cppcheck_xml_report.xml --report-dir=report
```

Ovi koraci se mogu naći u skripti [`cppcheck-htmlreport.sh`](cppcheck/cppcheck-htmlreport.sh).

Najviše upozorenja je tipa `style`, pri čemu su uočene funkcije koje su definisane a nekorišćene, nedostatak ključne reči override kod funkcija koje bi trebalo da pregaze istoimene funkcije iz bazne klase, napomena da neke promenljive mogu biti definisane kao `const`. Jedno od zanimljivijih preporuka se odnosi na definisanje `explicit` konstruktora ukoliko oni imaju samo jedan argument:

![](cppcheck/images/explicit-constructor.png)


Drugi zanimljiviji primeri iz izveštaja:

Upozorenje o "senčenju" promenljivih kada se radi grananje ili u petljama. Preporuka je da se koriste jedinstveni nazivi promenljivih radi lakše čitljivosti i izbegavanja grešaka.

![](cppcheck/images/cppcheck-shadowvar.png)

Upozorenje da se assert izrazi zanemaruju tokom prevođenja u `release` modu i da se funkcija koja ima sporedne efekte neće izvršavati u tom slučaju.

![](cppcheck/images/assert-side-effect.png)

Neki značajniji bagovi nisu uočeni analizom. Cppcheck je naredni deo koda označio kao `error`:

```
../vpaint/src/VAC/VectorAnimationComplex/Cell.cpp:580:5: error:There is an unknown macro here somewhere. Configuration is required. If foreach is a macro then please configure it. [unknownMacro]
    foreach(Cell * c, spatialBoundary())
```

Međutim, `foreach` makro se nalazi u okviru Qt biblioteke što statički analizator ne može da zna.

### Zaključak

Izveštaj dobijen analizom Cppcheck daje dobre preporuke za poboljšanje čitljivosti koda i izbegavanje potencijalnih grešaka. Ovaj alat je dobar dodatak uz prethodno korišćene Clang alate za statičku analizu jer prijavljuje upozorenja koja se nisu pojavila primenom drugih alata. Kao i za druge alate, moguča su lažna upozorenja jer Cppcheck ne analizira spoljašnje biblioteke.


## Valgrind

### Memcheck

### Cachegrind

## Perf
