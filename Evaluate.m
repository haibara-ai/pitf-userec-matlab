function [precision,recall,fmeasure,mrr,map] = Evaluate(test_posts,predict_posts)

predict_count = size(predict_posts,1)/length(unique(predict_posts(:,1)));
precision = zeros(predict_count,1);
recall = zeros(predict_count,1);
fmeasure = zeros(predict_count,1);
mrr = zeros(predict_count,1);
map = zeros(predict_count,1);

test_users = unique(test_posts(:,1));
test_user_count = size(test_users,1);

for i = 1:test_user_count
    test_frds = test_posts(test_posts(:,1) == test_users(i,1),2);
    predict_frds = predict_posts(predict_posts(:,1) == test_users(i,1),2);
    hit_count = 0;
    ap = 0;
    rr = 0;
    for j = 1:predict_count
        hit_count = hit_count + length(intersect(predict_frds(j,1),test_frds));
        hit_pos = find(test_frds == predict_frds(j));
        precision(j) = precision(j) + hit_count / j;
        recall(j) = recall(j) + hit_count / length(test_frds);
        ap = ap + hit_count / j;
        if ~isempty(hit_pos)
            rr = rr + 1 / hit_pos;
        end
        map(j) = map(j) + ap / length(test_frds);
        mrr(j) = mrr(j) + rr / length(test_frds);
    end    
end
map = map / test_user_count;
mrr = mrr / test_user_count;
precision = precision / test_user_count;
recall = recall / test_user_count;

for i = 1:predict_count
    if precision(i) == 0 || recall(i) == 0
        fmeasure(i) = 0;
    else
        fmeasure(i) = 2*precision(i)*recall(i) / (precision(i)+recall(i));
    end
    fprintf('top %d,precision is %f, recall is %f,fmeasure is %f\n',i,precision(i),recall(i),fmeasure(i));
end
fprintf('mrr is %f, map is %f\n',mrr,map);
end