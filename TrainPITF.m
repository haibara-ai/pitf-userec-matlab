function [U,T,F_U,F_T] = TrainPITF(frd_cases,num_user,num_tag,num_frd,num_feature,init_mean,init_std,regular,learn_rate,num_iteration,num_neg_samples,epsion)

%%
% Initialize matrix
U = GetNormMatrix(num_user,num_feature,init_mean,init_std);
T = GetNormMatrix(num_tag,num_feature,init_mean,init_std);
F_U = GetNormMatrix(num_frd,num_feature,init_mean,init_std);
F_T = GetNormMatrix(num_frd,num_feature,init_mean,init_std);

num_frd_case = size(frd_cases,1);
num_iteration_neg_samples = num_frd_case * num_neg_samples;
%% build friend case
% fprintf('build friend case...\n');
% num_frd_case = size(user_tag_friend,1);
% fprintf('num_frd_case:%d\n',num_frd_case);
% num_iteration_neg_samples = num_frd_case * num_neg_samples;
% frd_cases = cell(num_frd_case,4);
% user_tag_post = unique(user_tag_friend(:,1:2),'rows');
% fci = 1;
% for i = 1:size(user_tag_post,1)
%     post_frds = user_tag_friend(user_tag_friend(:,1) == user_tag_post(i,1) & user_tag_friend(:,2) == user_tag_post(i,2),3);
%     for j = 1:length(post_frds)
%         frd_cases{fci,1} = user_tag_post(i,1);
%         frd_cases{fci,2} = user_tag_post(i,2);
%         frd_cases{fci,3} = post_frds(j,1);
%         frd_cases{fci,4} = post_frds;        
%         fci = fci + 1;
%     end
% end
% fprintf('build friend case end...\n');
%% train
for i = 1:num_iteration
    fprintf('iteration %d...\n',i);
    start_t = clock;
    old_U = U;
    old_T = T;
    old_FU = F_U;
    old_FT = F_T;
    for j = 1:num_iteration_neg_samples
        p = ceil(rand * num_frd_case);
        uid = frd_cases{p,1};
        tid = frd_cases{p,2};
        fid_p = frd_cases{p,3};
        fid_n = DrawNegSample(num_frd,frd_cases{p,4});
        Learn(uid,tid,fid_p,fid_n);
    end
    diff = CalcIterationDiff(old_U,old_T,old_FU,old_FT);
    subplot(2,2,1);
    plot(i,diff(1));
    hold on;
    subplot(2,2,2);
    plot(i,diff(2));
    hold on;
    subplot(2,2,3);
    plot(i,diff(3));
    hold on;
    subplot(2,2,4);
    plot(i,diff(4));
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
    function local_score = PredictCaseScore(uid,tid,fid)
        uf_score = 0;
        tf_score = 0;
        for ii = 1:num_feature
            uf_score = uf_score + U(uid,ii)*F_U(fid,ii);
            tf_score = tf_score + T(tid,ii)*F_T(fid,ii);
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

    function Learn(uid,tid,fid_p,fid_n)
        local_score_p = PredictCaseScore(uid,tid,fid_p);
        local_score_n = PredictCaseScore(uid,tid,fid_n);
        normalizer = GetLNSigmodPartialLoss(local_score_p - local_score_n);
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
    end
end