;;
;;;;;;
;
; HX-2016-07:
; for Clojure code
; translated from ATS
;
;;;;;;
;;

;;
;;;;;;
; beg of [reference_cats.clj]
;;;;;;
;;

;; ****** ****** ;;
;;
(defmacro
 ats2cljpre_ref[x] `(atom ~x)
)
(defmacro
 ats2cljpre_ref_make_elt[x] `(atom ~x)
)
;;
;; ****** ****** ;;
;;
(defmacro
 ats2cljpre_ref_get_elt[r] `(deref ~r)
)
(defmacro
 ats2cljpre_ref_set_elt[r x0] `(reset! ~r ~x0)
)
;; HX-2026-10: for linear contents
(defmacro
 ats2cljpre_ref_exch_elt[r x0]
`(let [x1# (deref ~r)] (reset! ~r ~x0) x1#)
)
;;
;; ****** ****** ;;

;; end of [reference_cats.clj] ;;
