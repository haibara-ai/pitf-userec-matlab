function [U,T,F_U,F_T] = TrainKernelPITF(frd_cases,num_user,num_tag,num_frd,num_feature,init_mean,init_std,regular,learn_rate,num_iteration,num_neg_samples,epsion,kernel_type,varargin)
%% parameters: kernel type
% 1. linear kernel <w,h>
% 2. polynomial kernel (1+<w,h>)^d
% 3. RBF kernel exp(-||w-h||^2 / 2delta^2)
% 4. logistic kernel phi(b+<w,h>);
%%
% Initialize matrix
U = GetNormMatrix(num_user,num_feature,init_mean,init_std);
T = GetNormMatrix(num_tag,num_feature,init_mean,init_std);
F_U = GetNormMatrix(num_frd,num_feature,init_mean,init_std);
F_T = GetNormMatrix(num_frd,num_feature,init_mean,init_std);

num_frd_case = size(frd_cases,1);

%% train
for i = 1:num_iteration
    fprintf('iteration %d...\n',i);
    start_t = clock;
    old_U = U;
    old_T = T;
    old_FU = F_U;
    old_FT = F_T;
    rand_order = randperm(num_frd_case);
    for j = 1:num_frd_case        
        p = rand_order(j);
        uid = frd_cases{p,1};
        tid = frd_cases{p,2};
        fid_p = frd_cases{p,3};        
        for k = 1:num_neg_samples
            fid_n = DrawNegSample(num_frd,frd_cases{p,4});
            Learn(uid,tid,fid_p,fid_n,kernel_type);
        end
    end
    diff = CalcIterationDiff(old_U,old_T,old_FU,old_FT);
    subplot(2,2,1);
    plot(i,diff(1),'MarkerSize',10);
    hold on;
    subplot(2,2,2);
    plot(i,diff(2),'MarkerSize',10);
    hold on;
    subplot(2,2,3);
    plot(i,diff(3),'MarkerSize',10);
    hold on;
    subplot(2,2,4);
    plot(i,diff(4),'MarkerSize',10);
    hold on;
    disp(['cost time: ',num2str(etime(clock,start_t))]);
    fprintf('iteration diff: %f,%f,%f,%f\n',diff(1),diff(2),diff(3),diff(4));
    if sum(diff) < epsion
        break;
    end
end
hold off;
%% sub functions
    function local_diff = CalcIterationDiff(old_U,old_T,old_FU,old_FT)
        local_diff = zeros(4,1);
        local_diff(1) = norm(U-old_U,'fro');
        local_diff(2) = norm(T-old_T,'fro');
        local_diff(3) = norm(F_U-old_FU,'fro');
        local_diff(4) = norm(F_T-old_FT,'fro');        
    end
    function local_score = PredictCaseScore(uid,tid,fid,kernel_type)
        switch kernel_type
            case 1
                uf_score = MyDot(U(uid,:),F_U(fid,:));
                tf_score = MyDot(T(tid,:),F_T(fid,:));
            case 2                
                d = varargin{1};
                uf_score = (1+MyDot(U(uid,:),F_U(fid,:)))^d;
                tf_score = (1+MyDot(T(tid,:),F_T(fid,:)))^d;
            case 3
                delta2 = varargin{1}^2;
                uf_score = exp(-MyDot((U(uid,:)-F_U(fid,:)),(U(uid,:)-F_U(fid,:))) / (2*delta2));
                tf_score = exp(-MyDot((T(uid,:)-F_T(fid,:)),(T(uid,:)-F_T(fid,:))) / (2*delta2));                
            case 4
                b = varargin{1};
                uf_score = 1 / (1 + exp(-b-MyDot(U(uid,:),F_U(fid,:))));
                tf_score = 1 / (1 + exp(-b-MyDot(T(tid,:),F_T(fid,:))));                
            otherwise
                error(['invalid kernel type:' num2str(kernel_type)]);
        end
        local_score = uf_score + tf_score;
    end
    
    function ret = DrawNegSample(num_frd,fids_p)
        neg = ceil(rand*num_frd);
        while ~isempty(find(fids_p == neg, 1))
            neg = ceil(rand*num_frd);
        end 
        ret = neg;
    end

    function Learn(uid,tid,fid_p,fid_n,kernel_type)
        local_score_p = PredictCaseScore(uid,tid,fid_p,kernel_type);
        local_score_n = PredictCaseScore(uid,tid,fid_n,kernel_type);
        normalizer = GetLNSigmodPartialLoss(local_score_p - local_score_n);
        switch kernel_type
            case 1
                for ii = 1:num_feature
                    uf = U(uid,ii);
                    tf = T(tid,ii);
                    fuf_p = F_U(fid_p,ii);
                    fuf_n = F_U(fid_n,ii);
                    ftf_p = F_T(fid_p,ii);
                    ftf_n = F_T(fid_n,ii);
                    U(uid,ii) = U(uid,ii) + learn_rate * (normalizer * (fuf_p - fuf_n) - regular * uf);
                    T(tid,ii) = T(tid,ii) + learn_rate * (normalizer * (ftf_p - ftf_n) - regular * tf);
                    F_U(fid_p,ii) = F_U(fid_p,ii) + learn_rate * (normalizer * uf - regular * fuf_p);
                    F_U(fid_n,ii) = F_U(fid_n,ii) + learn_rate * (normalizer * (-uf) - regular * fuf_n);
                    F_T(fid_p,ii) = F_T(fid_p,ii) + learn_rate * (normalizer * tf - regular * ftf_p);
                    F_T(fid_n,ii) = F_T(fid_n,ii) + learn_rate * (normalizer * (-tf) - regular * ftf_n);            
                end
            case 2
                d = varargin{1};
                ufu_p_score = d*(1+MyDot(U(uid,:),F_U(fid_p,:)))^(d-1);
                ufu_n_score = d*(1+MyDot(U(uid,:),F_U(fid_n,:)))^(d-1);
                tft_p_score = d*(1+MyDot(T(tid,:),F_T(fid_p,:)))^(d-1);
                tft_n_score = d*(1+MyDot(T(tid,:),F_T(fid_n,:)))^(d-1);                
                for ii = 1:num_feature
                    uf = U(uid,ii);
                    tf = T(tid,ii);
                    fuf_p = F_U(fid_p,ii);
                    fuf_n = F_U(fid_n,ii);
                    ftf_p = F_T(fid_p,ii);
                    ftf_n = F_T(fid_n,ii);
                    U(uid,ii) = U(uid,ii) + learn_rate *(normalizer * (ufu_p_score*fuf_p-ufu_n_score*fuf_n) - regular * uf);
                    T(tid,ii) = T(tid,ii) + learn_rate *(normalizer * (tft_p_score*ftf_p-tft_n_score*ftf_n) - regular * tf);                    
                    F_U(fid_p,ii) = F_U(fid_p,ii) + learn_rate * (normalizer * (uf*ufu_p_score) - regular * fuf_p);
                    F_U(fid_n,ii) = F_U(fid_n,ii) + learn_rate * (normalizer * (-uf*ufu_n_score) - regular * fuf_n);
                    F_T(fid_p,ii) = F_T(fid_p,ii) + learn_rate * (normalizer * (tf*tft_p_score) - regular * ftf_p);
                    F_T(fid_n,ii) = F_T(fid_n,ii) + learn_rate * (normalizer * (-tf*tft_n_score) - regular * ftf_n);
                end
            case 3
                delta2 = varargin{1}^2;
                ufu_p_score = exp(-MyDot((U(uid,:)-F_U(fid_p,:)),(U(uid,:)-F_U(fid_p,:))) / (2*delta2));
                ufu_n_score = exp(-MyDot((U(uid,:)-F_U(fid_n,:)),(U(uid,:)-F_U(fid_n,:))) / (2*delta2));                
                tft_p_score = exp(-MyDot((T(tid,:)-F_T(fid_p,:)),(T(tid,:)-F_T(fid_p,:))) / (2*delta2));
                tft_n_score = exp(-MyDot((T(tid,:)-F_T(fid_n,:)),(T(tid,:)-F_T(fid_n,:))) / (2*delta2));                
                for ii = 1:num_feature
                    uf = U(uid,ii);
                    tf = T(tid,ii);
                    fuf_p = F_U(fid_p,ii);
                    fuf_n = F_U(fid_n,ii);
                    ftf_p = F_T(fid_p,ii);
                    ftf_n = F_T(fid_n,ii);                    
                    U(uid,ii) = U(uid,ii) + learn_rate * (normalizer * (ufu_n_score*(uf-fuf_n)-ufu_p_score*(uf-fuf_p))/delta2 - regular * uf);
                    T(tid,ii) = T(tid,ii) + learn_rate * (normalizer * (tft_n_score*(tf-ftf_n)-tft_p_score*(tf-ftf_p))/delta2 - regular * tf);                  
                    F_U(fid_p,ii) = F_U(fid_p,ii) + learn_rate * (normalizer * (ufu_p_score*(uf-fuf_p)/delta2) - regular * fuf_p);
                    F_U(fid_n,ii) = F_U(fid_n,ii) + learn_rate * (normalizer * (-ufu_n_score*(uf-fuf_n)/delta2) - regular * fuf_n);
                    F_T(fid_p,ii) = F_T(fid_p,ii) + learn_rate * (normalizer * (tft_p_score*(tf-ftf_p)/delta2) - regular * ftf_p);
                    F_T(fid_n,ii) = F_T(fid_n,ii) + learn_rate * (normalizer * (-tft_n_score*(tf-ftf_n)/delta2) - regular * ftf_n);                    
                end
            case 4
                b = varargin{1};
                ufu_p_score = GetSigmodPartialLoss(b+MyDot(U(uid,:),F_U(fid_p,:)));
                ufu_n_score = GetSigmodPartialLoss(b+MyDot(U(uid,:),F_U(fid_n,:)));
                tft_p_score = GetSigmodPartialLoss(b+MyDot(T(tid,:),F_T(fid_p,:)));
                tft_n_score = GetSigmodPartialLoss(b+MyDot(T(tid,:),F_T(fid_n,:)));                
                for ii = 1:num_feature
                    uf = U(uid,ii);
                    tf = T(tid,ii);
                    fuf_p = F_U(fid_p,ii);
                    fuf_n = F_U(fid_n,ii);
                    ftf_p = F_T(fid_p,ii);
                    ftf_n = F_T(fid_n,ii);
                    U(uid,ii) = U(uid,ii) + learn_rate *(normalizer * (ufu_p_score*fuf_p-ufu_n_score*fuf_n) - regular * uf);
                    T(tid,ii) = T(tid,ii) + learn_rate *(normalizer * (tft_p_score*ftf_p-tft_n_score*ftf_n) - regular * tf);                    
                    F_U(fid_p,ii) = F_U(fid_p,ii) + learn_rate * (normalizer * (uf*ufu_p_score) - regular * fuf_p);
                    F_U(fid_n,ii) = F_U(fid_n,ii) + learn_rate * (normalizer * (-uf*ufu_n_score) - regular * fuf_n);
                    F_T(fid_p,ii) = F_T(fid_p,ii) + learn_rate * (normalizer * (tf*tft_p_score) - regular * ftf_p);
                    F_T(fid_n,ii) = F_T(fid_n,ii) + learn_rate * (normalizer * (-tf*tft_n_score) - regular * ftf_n);
                end
            otherwise
                error(['invalid kernel type:' num2str(kernel_type)]);
        end
    end
    function local_ret = MyDot(a,b)
        local_ret = 0;
        for ii = 1:num_feature
            local_ret = local_ret + a(ii) * b(ii);
        end
    end
end