function [Xt,RMSE_V,Q,Vt,Qd,dVdQ] = diagnostics_recal(Q_data,Vt_data,Up,Un,Xi,i,Cn,x100)



V = @(X,Q) Up(X(1)+Q/X(2))-Un(x100(i)-Q/Cn(i));



Vt_data = flipud(Vt_data);
Q1 = Q_data(1);
Q_data = flipud(max(Q_data)-Q_data);


L = 0;
S = [20;1/5];
lb = [0.0;2;0.0];
ub = [0.1;4;1.0];

% L = 0;
% S = [20;1/6;1;1/6];
lb2 = [Xi(1)*0.9;Xi(2)*0.80];
ub2 = [Xi(1)*1.1;Xi(2)*1.00];


%         fun = @(X) (V(X./S,Q_data)-Vt_data)'*(V(X./S,Q_data)-Vt_data)+L*norm((X-Xi)./S,2);
        fun = @(X) norm(V(X./S,Q_data)-Vt_data,1);
        nonCon = @(X) connon(X./S,4.20,3.0,max(Q_data),Up,Un,Cn,x100,i);
        options = optimoptions('fmincon','Display','iter','Algorithm','sqp','OptimalityTolerance',1e-7,'MaxFunctionEvaluations',9000);
%         if i == 1
%             problem = createOptimProblem('fmincon','x0',Xi.*S,'objective',fun,'lb',lb.*S,'ub',ub.*S,'nonlcon',nonCon,'options',options);
%             gs = GlobalSearch;
%             [Xr,fval,exitflag,output,manymins] = run(gs,problem);
%         else
            [Xr,fval,exitflag] = fmincon(fun,Xi.*S,[],[],[],[],lb2.*S,ub2.*S,nonCon,options);
%         end
        RMSE_V = sqrt((V(Xr./S,Q_data)-Vt_data)'*(V(Xr./S,Q_data)-Vt_data)/length(Q_data));





Xt = Xr./S;

Q = 0:0.01:(max(Q_data)-Q1);



Vt = V(Xt,Q);
dV = Vt(2:end)-Vt(1:end-1);
dQ = Q(2:end)-Q(1:end-1);
Qd = Q(1:end-1)+(Q(2:end)-Q(1:end-1))./2;





dVdQ = dV./dQ;         

end



function [c,ceq] = connon(X,Vmax,Vmin,Qmax,Up,Un,Cn,x100,i)
ceq(1) = Up(X(1))-Un(x100(i))-Vmax;
% ceq(2) = Up(X(1)+(Qmax+X(3))/X(2))-Un(x100(i)-(Qmax+X(3))/Cn(i))-Vmin;
c = [];
end