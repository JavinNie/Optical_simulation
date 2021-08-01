function [x_out, y_out] = mCoordinate(x_in, y_in, m_theta_ref, n)
if ((x_in==0) && (y_in==0))
else
    m_theta = atan2(y_in, x_in)/pi*180;
    m_rohn = (x_in^2 + y_in^2)^0.5;
    while((m_theta<m_theta_ref-180/n)||(m_theta>m_theta_ref+180/n))
        m_theta = m_theta + 360/n;
        x_in = m_rohn*cosd(m_theta);
        y_in = m_rohn*sind(m_theta);
        m_theta = atan2(y_in, x_in)/pi*180;
    end
end
x_out = x_in;
y_out = y_in;
end