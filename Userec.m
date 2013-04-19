function ret = Userec(utf_tensor,train_friend_cases,user_tag_cell,train_user_friend,test_user_friend,num_feature)

regular = 0.00005;
learn_rate = 0.005;
init_mean = 0;
init_std = 0.01;
num_iteration = 100;
num_neg_samples = 1;
epsion = 0.01;
num_user = size(utf_tensor,1);
num_tag = size(utf_tensor,2);
num_frd = size(utf_tensor,3);
top_N = 100;
%% train
fprintf('train pitf...\n');
start_t = clock;
[U,T,F_U,F_T] = TrainPITF(train_friend_cases,num_user,num_tag,num_frd,num_feature,init_mean,init_std,regular,learn_rate,num_iteration,num_neg_samples,epsion);
train_t = etime(clock,start_t);
disp(['cost time: ',num2str(train_t)]);
fprintf('train pitf end...\n');

%% predict top friends based on each tag
model_file = [num2str(month(now)) '_' num2str(day(now)) '_' num2str(hour(now)) '_' num2str(minute(now)) '_' num2str(second(now)) '_dim' num2str(num_feature) '_pitf_model'];
save(['./pitf-data/' model_file '.mat'],'U','T','F_U','F_T');
fprintf('predict...\n');
predict_dim = 4;
test_users = unique(test_user_friend(:,1));
num_frds = size(F_U,1);
per_user_predict_cell = cell(length(test_users));
for i = 1:length(test_users)
    tags = user_tag_cell{test_users(i)};
    per_tag_predict_cell = cell(length(tags),1);
    for j = 1:length(tags)
        temp_ret = PredictTopFrds(test_users(i),tags(j));
        temp_ret_count = size(temp_ret,1);
        per_tag_predict_cell{j,1} = [test_users(i)*ones(1,temp_ret_count);tags(j)*ones(1,temp_ret_count);temp_ret']';        
    end
    per_tag_predict = DecellPredictRet(per_tag_predict_cell);
    per_user_predict_cell{i,1} = per_tag_predict;
end
per_user_predict = DecellPredictRet(per_user_predict_cell);
%% fusion rank
userec = FusionRankByRRF(test_user_friend,per_user_predict,top_N);
save(['./pitf-data/' model_file '_predict.mat'],'userec');
fprintf('predict end...\n');
%% evaluate result
fprintf('evaluate...\n');
[precison,recall,fmeasure,mrr,map] = Evaluate(test_user_friend,userec);
fprintf('predict end...\n');
ret = cell(6,1);
ret{1} = precison;
ret{2} = recall;
ret{3} = fmeasure;
ret{4} = mrr;
ret{5} = map;
ret{6} = train_t;
save(['./pitf-data/' model_file '_evaluate.mat'],'ret');
saveas(gcf,['./pitf-data/' model_file '.fig']);
%% sub functions
    function ret = PredictTopFrds(uid,tid)
        predict_frds = zeros(num_frds,2);
        train_friends = train_user_friend(train_user_friend(:,1) == uid,2);
        for ii = 1:num_frds
            if ~isempty(find(train_friends == ii,1))
                continue;
            end
            predict_frds(ii,1) = ii;
            temp = 0;
            for jj = 1:num_feature
                temp = temp + U(uid,jj)*F_U(ii,jj) + T(tid,jj)*F_T(ii,jj);
            end
            predict_frds(ii,2) = temp;
        end
        predict_frds(predict_frds(:,1) == 0,:) = [];
        ret = sortrows(predict_frds,-2);
    end

    function ret = DecellPredictRet(predict_cell)
        cell_count = size(predict_cell,1);
        ctr = 0;
        for ii = 1:cell_count
            ctr = ctr + size(predict_cell{ii},1);
        end
        ret = zeros(ctr,predict_dim);
        index = 1;
        for ii = 1:cell_count
            ret(index:index+size(predict_cell{ii},1)-1,:) = predict_cell{ii};
            index = index + size(predict_cell{ii},1);
        end
    end
end