function [] = FilledCircle(x,y,Radius,Colour,Parent)

    th = 0:pi/50:2*pi;
    x_circle = Radius * cos(th) + x;
    y_circle = Radius * sin(th) + y;
    
    %circles = plot(x_circle, y_circle, 'Parent', Parent, 'PickableParts','none', 'Hittest','off');
    fill(Parent, x_circle, y_circle, Colour, 'EdgeColor', 'none','PickableParts','none', 'Hittest','off');
end
