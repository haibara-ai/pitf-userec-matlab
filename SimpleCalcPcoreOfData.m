function ret = SimpleCalcPcoreOfData(data,pcore)
ret = data;
dim_count = size(ret,2);
fprintf('new iteration, post count : %d\r\n',size(ret,1));
goon = 1;
while goon == 1
    goon = 0;
    for i = 1:dim_count
        erase_index = zeros(size(ret,1),1);
        fprintf('dim : %d\r\n',i);
        unique_seeds = unique(ret(:,i));
        erase_item_count = zeros(length(unique_seeds),1);
        unique_seeds_len = length(unique_seeds);
        parfor j = 1:unique_seeds_len
            item_index = logical(ret(:,i) == unique_seeds(j));            
            if sum(item_index) < pcore
    %             erase_index = [erase_index;item_index];
               erase_item_count(j) = 1;
            end
        end
        erase_item_index = unique_seeds(logical(erase_item_count == 1),1);
        fprintf('item < pcore count : %d\n',length(erase_item_index));
        if isempty(erase_item_index) == 0
            parfor j = 1:size(ret,1)
                if isempty(find(erase_item_index == ret(j,i),1)) == 0
                    erase_index(j,1) = 1;
                end
            end
        end
        if sum(erase_index) > 0
            goon = 1;
        end
        ret(logical(erase_index == 1),:) = [];
    end
end
end