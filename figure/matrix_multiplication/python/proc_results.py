import numpy as np
import scipy
import pstats

List_N=np.array([2**7,2**8,2**9,2**10,2**11,2**12,2**13])
t=np.zeros([6,7])
for i in range(np.size(List_N)):
    N=List_N[i]
    for rp in range(6):
        rpp=rp
        if i==6:
            rpp=1
        p = pstats.Stats('figure/matrix_multiplication/python/results/Strassen/stats_plain_{}_{}'.format(rpp,i))
        t[rp][i]=p.total_tt

mdic={'t':t,'List_N':List_N}
scipy.io.savemat('figure/matrix_multiplication/python/results/plain/stats_all_plain',mdic)


List_N=np.array([2**7,2**8,2**9,2**10,2**11,2**12,2**13])
t=np.zeros([6,7])
for i in range(np.size(List_N)):
    N=List_N[i]
    for rp in range(6):
        rpp=rp
        if i==6:
            rpp=1
        p = pstats.Stats('figure/matrix_multiplication/python/results/plain_8x8/stats_plain_8x8_{}_{}'.format(rpp,i))
        t[rp][i]=p.total_tt

mdic={'t':t,'List_N':List_N}
scipy.io.savemat('figure/matrix_multiplication/python/results/plain_8x8/stats_all_plain_8x8',mdic)


List_N=np.array([2**7,2**8,2**9,2**10,2**11,2**12,2**13])
t=np.zeros([6,7])
for i in range(np.size(List_N)):
    N=List_N[i]
    for rp in range(6):
        rpp=rp
        if i==6:
            rpp=1
        p = pstats.Stats('figure/matrix_multiplication/python/results/Strassen/stats_strassen_{}_{}'.format(rpp,i))
        t[rp][i]=p.total_tt

mdic={'t':t,'List_N':List_N}
scipy.io.savemat('figure/matrix_multiplication/python/results/Strassen/stats_all_Strassen',mdic)
