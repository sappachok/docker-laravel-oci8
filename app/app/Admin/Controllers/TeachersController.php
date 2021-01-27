<?php

namespace App\Admin\Controllers;

use App\Models\Teachers;
use Encore\Admin\Controllers\AdminController;
use Encore\Admin\Form;
use Encore\Admin\Grid;
use Encore\Admin\Show;

class TeachersController extends AdminController
{
    /**
     * Title for current resource.
     *
     * @var string
     */
    protected $title = 'Teachers';

    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        $grid = new Grid(new Teachers());

        $grid->column('id', __('Id'));
        $grid->column('first_name', __('First name'));
        $grid->column('last_name', __('Last name'));
        $grid->column('address', __('Address'));
        $grid->column('email', __('Email'));
        $grid->column('person_code', __('Person code'));
        $grid->column('created_at', __('Created at'));
        $grid->column('updated_at', __('Updated at'));

        return $grid;
    }

    /**
     * Make a show builder.
     *
     * @param mixed $id
     * @return Show
     */
    protected function detail($id)
    {
        $show = new Show(Teachers::findOrFail($id));

        $show->field('id', __('Id'));
        $show->field('first_name', __('First name'));
        $show->field('last_name', __('Last name'));
        $show->field('address', __('Address'));
        $show->field('email', __('Email'));
        $show->field('person_code', __('Person code'));
        $show->field('created_at', __('Created at'));
        $show->field('updated_at', __('Updated at'));

        return $show;
    }

    /**
     * Make a form builder.
     *
     * @return Form
     */
    protected function form()
    {
        $form = new Form(new Teachers());

        $form->text('first_name', __('First name'));
        $form->text('last_name', __('Last name'));
        $form->textarea('address', __('Address'));
        $form->email('email', __('Email'));
        $form->text('person_code', __('Person code'));

        return $form;
    }
}
