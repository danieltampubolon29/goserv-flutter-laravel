@extends('layouts.aplication')
@section('title', 'Dashboard')
@section('content')
    <x-bar.navbar>Dashboard
        <x-slot name="content">
            <div class="container mt-4">
                <div class="card shadow">
                    <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Daftar Pencairan</h5>
                    </div>
                    
                </div>
            </div>
            <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
            <script src="{{ asset('js/all/show.js') }}"></script>
        </x-slot>
    </x-bar.navbar>
@endsection
