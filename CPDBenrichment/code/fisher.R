
fisher<-function(target_A,target_B,bg,alternative="greater"){
  target_A = intersect(target_A,bg)
  target_B = intersect(target_B,bg)
  aa=length(intersect(target_A,target_B))
  bb=sum(!target_B%in%target_A)
  cc=sum(!target_A%in%target_B)
  dd=sum(!bg%in%union(target_B,target_A))
  model=fisher.test(matrix(c(aa,bb,cc,dd),2,2),alternative="greater")
  return(model$p.value)
}


chisq<-function(target_A,target_B,bg,alternative="greater"){
  target_A = intersect(target_A,bg)
  target_B = intersect(target_B,bg)
  aa=length(intersect(target_A,target_B))
  bb=sum(!target_B%in%target_A)
  cc=sum(!target_A%in%target_B)
  dd=sum(!bg%in%union(target_B,target_A))
  model=chisq.test(matrix(c(aa,bb,cc,dd),2,2))
  return(model$p.value)
}