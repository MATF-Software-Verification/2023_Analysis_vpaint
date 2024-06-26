# 2023_Analysis_vpaint

## :memo: Informacije o projektu

- U ovom radu predstavljena je analiza projekta VPaint koji se može naći na adresi https://github.com/dalboris/vpaint/. Analiza je rađena nad `master` granom sa commit hešom `58593fe8050376fad7195603c03f8d8851fa775d`. U radu je opisan način primene različitih alata za verifikaciju kao i rezultati njihove primene i zaključci.

- VPaint je projekat otvorenog koda namenjen za grafički dizajn i 2D animaciju. Za implementaciju projekta korišćen je programski jezik C++17, razvojni okvir Qt5, biblioteke OpenGL i Eigen. Za detaljne instrukcije o instalaciji i pokretanju projekta pogledati **Build Instructions** sekciju `README.md` fajla u repozitorijumu VPaint-a: https://github.com/dalboris/vpaint/?tab=readme-ov-file#build-instructions.

## :hammer_and_wrench: Korišćeni alati/tehnike

- Clang
    - Clang-Tidy
    - Clazy
- Cppcheck
- Valgrind
    - Memcheck
    - Cachegrind
- Perf

## :memo: Zaključak

Projekat je prilično kvalitetan ali i dosta obiman, pa samim tim i postoje propusti u vidu mrtvog koda, slabe čitljivosti, stilskih propusta. Što se tiče performansi - nisu uočeni veći propusti. Bilo bi dobro refaktorisati neke metode radi bolje čitljivosti, međutim pohvalno je što postoji veliki broj komentara u kodu koji predstavljaju dokumentaciju ili razjašnjavaju logiku neke funkcije.

Po [rečima autora](https://github.com/dalboris/vpaint/?tab=readme-ov-file#disclaimer) VPaint-a, ovaj projekat je više eksperimentalnog i istraživačkog tipa, pa samim tim je program nestabilniji i sklon greškama.

## :woman_technologist: Autor

**Tatjana Kunić, 1084/2022**