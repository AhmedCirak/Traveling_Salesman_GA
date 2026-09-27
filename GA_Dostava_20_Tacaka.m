function GA_Dostava_20_Tacaka()
    
    % PARAMETRI PROBLEMA I KOORDINATE 
   
    startTacka = [5, 5];
    ciljTacka = [95, 95];
    
    % Generisanje 20 nasumičnih tačaka 
    rng(1); 
    dostavneTacke = randi([10, 90], 20, 2); 
    
    brojTacaka = size(dostavneTacke, 1); 
    
    rng('shuffle')
    % GA PARAMETRI 
    
    velicinaPopulacije = 50;  
    brojGeneracija = 100;     
    vjerovatnocaUkrstanja = 0.8;
    vjerovatnocaMutacije = 0.1; 
    
    brojPokretanja = 3; 
    sveIstorije = zeros(brojGeneracija, brojPokretanja); 
    
    apsolutnoNajboljiFitnes = inf; 
    apsolutnoNajboljaRuta = [];

    % VIŠESTRUKo POKRETANJe
    for pokretanje = 1:brojPokretanja
        
        fprintf('\n--- Pokretanje %d ---\n', pokretanje);
        
        % INICIJALIZACIJA POPULACIJE
        populacija = zeros(velicinaPopulacije, brojTacaka);
        for i = 1:velicinaPopulacije
            populacija(i, :) = randperm(brojTacaka);
        end
        
        istorijaNajboljih = zeros(brojGeneracija, 1);
        najboljaRutaSveukupno = [];
        najboljiFitnesSveukupno = inf;
        
        % GLAVNA GA PETLJA
        for gen = 1:brojGeneracija
            fitnesVrijednosti = zeros(velicinaPopulacije, 1);
            
            for i = 1:velicinaPopulacije
                fitnesVrijednosti(i) = izracunajUdaljenost(populacija(i, :), dostavneTacke, startTacka, ciljTacka);
            end
            
            [trenutnoNajboljiFitnes, najboljiIndeks] = min(fitnesVrijednosti);
            istorijaNajboljih(gen) = trenutnoNajboljiFitnes;
            
            if mod(gen, 20) == 0 
                fprintf('Generacija %d: Najkraća udaljenost = %.2f\n', gen, trenutnoNajboljiFitnes);
            end
            
            if trenutnoNajboljiFitnes < najboljiFitnesSveukupno
                najboljiFitnesSveukupno = trenutnoNajboljiFitnes;
                najboljaRutaSveukupno = populacija(najboljiIndeks, :);
            end
            
            novaPopulacija = zeros(velicinaPopulacije, brojTacaka);
            novaPopulacija(1, :) = populacija(najboljiIndeks, :); 
            
            for i = 2:2:velicinaPopulacije
                roditelj1 = populacija(turnir(fitnesVrijednosti), :);
                roditelj2 = populacija(turnir(fitnesVrijednosti), :);
                
                if rand < vjerovatnocaUkrstanja
                    [dijete1, dijete2] = orderCrossover(roditelj1, roditelj2);
                else
                    dijete1 = roditelj1; dijete2 = roditelj2;
                end
                
                dijete1 = swapMutacija(dijete1, vjerovatnocaMutacije);
                dijete2 = swapMutacija(dijete2, vjerovatnocaMutacije);
                
                novaPopulacija(i, :) = dijete1;
                if i + 1 <= velicinaPopulacije
                    novaPopulacija(i+1, :) = dijete2;
                end
            end
            populacija = novaPopulacija;
        end
        
        % Sačuvaj historiju ovog pokretanja
        sveIstorije(:, pokretanje) = istorijaNajboljih;
        
        % Provjeri da li je ovo pokretanje dalo apsolutno najbolju rutu
        if najboljiFitnesSveukupno < apsolutnoNajboljiFitnes
            apsolutnoNajboljiFitnes = najboljiFitnesSveukupno;
            apsolutnoNajboljaRuta = najboljaRutaSveukupno;
        end
    end
    
   
    % VIZUALIZACIJA 
    figure('Name', 'Optimizacija Rute - 20 Dostavnih Tačaka', 'Position', [50, 100, 1400, 450]);
    
    % Graf 1 sve moguće rute 
    subplot(1, 3, 1); hold on; grid on;
    title('Moguće veze (20 tačaka)');
    sveTacke = [startTacka; dostavneTacke; ciljTacka];
    for i = 1:size(sveTacke, 1)
        for j = i+1:size(sveTacke, 1)
            plot([sveTacke(i,1), sveTacke(j,1)], [sveTacke(i,2), sveTacke(j,2)], 'Color', [0.9 0.9 0.9]);
        end
    end
    iscrtajTacke(startTacka, dostavneTacke, ciljTacka);
    
    % Graf 2 fitnes kroz generacije 
    subplot(1, 3, 2); hold on; grid on;
    boje = {'r-', 'b-', 'g-'}; % Crvena, plava, zelena linija
    for pokretanje = 1:brojPokretanja
        plot(sveIstorije(:, pokretanje), boje{pokretanje}, 'LineWidth', 1.5);
    end
    title('Fitnes tokom generacija (Ukrštanja 0.9, Populacija 100, Mutacija 0.15)');
    xlabel('Generacija'); ylabel('Udaljenost');
    legend('Pokretanje 1', 'Pokretanje 2', 'Pokretanje 3');
    
    % Graf 3 optimalna ruta (koristi najbolju)
    subplot(1, 3, 3); hold on; grid on;
    title(sprintf('Finalna Ruta (Najbolja udaljenost: %.2f)', apsolutnoNajboljiFitnes));
    punaPutanja = [startTacka; dostavneTacke(apsolutnoNajboljaRuta, :); ciljTacka];
    
    plot(punaPutanja(:,1), punaPutanja(:,2), 'k-', 'LineWidth', 1.5);
    for i = 1:(size(punaPutanja, 1)-1)
        dp = punaPutanja(i+1,:) - punaPutanja(i,:);
        quiver(punaPutanja(i,1), punaPutanja(i,2), dp(1), dp(2), 0, 'k', 'LineWidth', 1.2, 'MaxHeadSize', 0.2);
    end
    iscrtajTacke(startTacka, dostavneTacke, ciljTacka);
end

% FUNKCIJE 

function dist = izracunajUdaljenost(hromozom, dostavneTacke, startT, ciljT)
    ruta = [startT; dostavneTacke(hromozom, :); ciljT];
    dist = sum(sqrt(sum(diff(ruta).^2, 2))); 
end

function idx = turnir(fitnesVrijednosti)
    k = 5; 
    kandidati = randi(length(fitnesVrijednosti), k, 1);
    [~, pobjednik] = min(fitnesVrijednosti(kandidati));
    idx = kandidati(pobjednik);
end

function [d1, d2] = orderCrossover(r1, r2)
    n = length(r1);
    cp = sort(randperm(n, 2));
    d1 = zeros(1,n); d2 = zeros(1,n);
    d1(cp(1):cp(2)) = r1(cp(1):cp(2));
    d2(cp(1):cp(2)) = r2(cp(1):cp(2));
    rem2 = r2(~ismember(r2, d1)); d1(d1==0) = rem2;
    rem1 = r1(~ismember(r1, d2)); d2(d2==0) = rem1;
end

function h = swapMutacija(h, prob)
    if rand < prob
        idx = randperm(length(h), 2);
        h([idx(1) idx(2)]) = h([idx(2) idx(1)]);
    end
end

function iscrtajTacke(st, dt, ct)
    plot(st(1), st(2), 'go','MarkerFaceColor','g');
    plot(ct(1), ct(2), 'bo','MarkerFaceColor','b');
    plot(dt(:,1), dt(:,2), 'ro','MarkerSize',5);
    axis square;
end