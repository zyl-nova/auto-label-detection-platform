<template>
    <div class="aside-head" >
        <span class="font-class" >项目列表</span>
    </div>
    <div class="aside-tree-content">
        <div class="filter-tree-input">
            <svg-icon v-show="hideCircle" style="padding-left: 2%;color: white;"  iconName="icon-quan"></svg-icon>
            <input style="border:0px;background-color: transparent;" type="text" v-model="searchQuery" placeholder="请输入项目名称/项目ID" @focus="dealFocus" @blur="dealBlur">
        </div>
        <div v-for="node in filteredTree" :key="node.id">
            <TreeNode :node="node" />
        </div>
    </div>
</template>

<script setup lang="ts">
import {ref, computed, onMounted} from 'vue'
import TreeNode from '@/components/treeNode/index.vue'
import cloneDeep from 'lodash/cloneDeep';
import request from '@/utils/request';
import allStore from '@/stores';

const {aside} = allStore()

const searchQuery = ref('')
const hideCircle = ref(true)

const treeData = ref([
    {
        id: 1,
        label: 'Node 1',
        children: [
            {
            id: 2,
            label: 'Node 1.1',
            children: []
            },
            {
            id: 3,
            label: 'Node 1.2',
            children: [
                {
                id: 4,
                label: 'Node 1.2.1',
                children: []
                }
            ]
            }
        ]
    },
    {
        id: 5,
        label: 'Node 2',
        children: [
           {
            id: 6,
            label: 'Node 2.1',
            children: [{
                id: 7,
                label: 'Node 2.1.1',
                children: []
            } ]
           } 
        ]
    }
])
const filterTree = (nodes:any, query:any) => {
    if(Array.isArray(nodes)){
        return nodes
        .filter((node:any) => {
            if (node.children) {

                node.children = filterTree(node.children, query)
            }
            return (
                node.label.toLowerCase().includes(query.toLowerCase()) ||
                (node.children && node.children.length)
            )
        })
    }
}
const filteredTree = computed(() => {
    let tmpList = cloneDeep(treeData.value)
    return filterTree(tmpList, searchQuery.value)
})

const dealFocus = () => {
    hideCircle.value = false
}

const dealBlur = () => {
    hideCircle.value = true
}

onMounted(()=>{
    (async function(){
        let list = await request.post('/AIModuleServer/ModelCenter/listTree')
        let listTmp = list.data.data
        listTmp.forEach((e:any) => {
            e.label = e.name
            e.value = e.id
            e.children.forEach((c:any) => {
                c.label = c.name
                c.value = c.id
            })
        })
        treeData.value = listTmp
        aside.setProjTreeList(listTmp)
        aside.setCurrentProjId(listTmp[0].children[0].id)
    })()
    
})

</script>

<style lang="scss" scoped>
.aside-head{
    height: 10%;
    width: 100%;
    background-color: rgb(0, 21, 41);
    display: flex;
    align-items: end;
    .font-class{
        color: white;
        font-size: 1.3em;
        padding-bottom: 0.5em;
        padding-left: 0.5em;
    }
}

.filter-tree-input{
    display: flex;
    justify-items: center;
    align-items: center;
    background-color: rgb(51, 53, 54);
    height: 5%;
    input{
        border:0px;
        background-color: transparent;
        margin-left: 2%;
        &::placeholder{
            font-size: small;
        }
        &:focus{
            outline: none;
            box-shadow: none;
        }
    }
}

.aside-tree-content{
    height: 90%;
    display: flex;
    flex-direction: column;
    background-color: rgb(240, 240, 240);
}

</style>

