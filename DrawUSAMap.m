clear; 

    load StateClusterNames;

    cCol(:,1) = [0.9290, 0.6940, 0.3250]; % yellow
    cCol(:,3) = [0.6350, 0.0780, 0.1840]; %red
    cCol(:,4) = [0.4660, 0.6740, 0.1880]; %green
    cCol(:,2) = [0.7500, 0.4250, 0.3980]; %orange
    cCol(:,5) = [0.1500, 0.2250, 0.7980]; %blue
    

    figure(1); clf;
    ax = usamap('all');
    set(ax, 'Visible', 'off')
    for c = 1:nClust
        str = sprintf('id = id%d;',c);
        eval(str);
        for i=1:length(id)
        
            fname = TXT{id(i)};
            vari = shaperead('usastatehi', 'UseGeoCoords', true,...
                            'Selector',{@(name) strcmpi(name,fname), 'Name'});
            if strcmp(fname,'Alaska')
                g= geoshow(ax(2), vari, 'FaceColor', cCol(:,c));
            elseif strcmp(fname,'Hawaii')
                g = geoshow(ax(3), vari, 'FaceColor', cCol(:,c));
            else
                g = geoshow(ax(1), vari, 'FaceColor', cCol(:,c));
            end
            if i == 1
                    str = sprintf('g%d = g;',c);
                    eval(str);
            end
            %textm(vari.LabelLat, vari.LabelLon, vari.Name,...
            %            'HorizontalAlignment', 'center');
        end
    end
    legend([g1 g2 g3 g4],'Cluster 1','Cluster 2','Cluster 3','Cluster 4');
    %legend([g1 g2 g3 g4 g5],'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5');
for k = 1:3
    setm(ax(k), 'Frame', 'off', 'Grid', 'off',...
      'ParallelLabel', 'off', 'MeridianLabel', 'off')
end

set(gca,'fontsize', 20);