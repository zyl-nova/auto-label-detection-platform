<template>
    <div>
        <div @click="toggle">
            <span v-if="node.children && node.children.length">
                {{ isOpen ? '-' : '+' }}
            </span>
            {{ node.label }}
        </div>
        <div v-show="isOpen" class="children"  v-for="child in node.children" :key="child.id">
            <TreeNode :node="child"  @click="changeProj(child)"/>
        </div>
    </div>
</template>

<script  lang="ts">
export default {
  name: "TreeNode", 
};
</script>

<script setup lang="ts">
import type {PropType} from 'vue'
import { reactive, ref } from 'vue';
import allStore from '@/stores';

const {aside} = allStore()

// 定义组件的props
const props = defineProps({
    node:{
        type: Object as PropType<{ id: number, label: string, children: Array<any> }>,
        required: true
    }
})
const isOpen = ref(false)

function toggle () {
    isOpen.value = !isOpen.value
}

const changeProj = (child:any) => {
    aside.setCurrentProjId(child.value)
}


</script>

<style lang="scss" scoped>
.children {
  padding-left: 20px;
}

</style>
