function ComponentMasks = RemoveOverlapComponent(ComponentMasks,overlapThresh)
% Function to remove components that have too strong an overlap
% with an additional component
%
% Shaul Druckmann, JFRC, June 2010

remPair = [];
for ii=1:(length(ComponentMasks)-1)
  for jj=(ii+1):length(ComponentMasks)
    A = nnz(ComponentMasks{ii});
    B = nnz(ComponentMasks{jj});
    C = nnz(ComponentMasks{ii} & ComponentMasks{jj});
    [m,order] = min([A B]);
    if C>0; overlapFrac = C/m;  end
    if C>0 && overlapFrac>=overlapThresh
      remPair = [remPair; [ii jj]];
    end
  end
end

if ~isempty(remPair)
  ComponentMasks(remPair(:,1)) = [];
end

end