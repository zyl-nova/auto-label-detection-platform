import asideStore from "./asideStore";
import labelStore from "./labelStore";
import currentUserSotre from "./currentUserStore";
import { useBusinessStore } from "./businessStore";


//统一导出store
export default function allStore(){
    return {
        aside: asideStore(),
        label: labelStore(),
        currentUser: currentUserSotre(),
        business: useBusinessStore(),
    }
}
